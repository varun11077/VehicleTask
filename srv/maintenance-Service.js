
'use strict';

const cds = require('@sap/cds');
const {
    validateVehicle,
    alertStatusCriticality,
    computeFuelEfficiency,
    addMonths
} = require('./utils/validators');

module.exports = cds.service.impl(async function () {

    const { ServiceRecords, FuelLogs, MaintenanceAlerts, Vehicles } = this.entities;


    this.after('READ', MaintenanceAlerts, (results) => {
        const rows = Array.isArray(results) ? results : [results];
        for (const row of rows) {
            if (row && row.Status !== undefined) {
                row.AlertCriticality = alertStatusCriticality(row.Status);
            }
        }
    });



    this.before('CREATE', FuelLogs, async (req) => {
        const { Vehicle_ID, Odometer, Liters } = req.data;

        if (!Vehicle_ID || !Odometer || !Liters) return; // nothing to compute


        const vehicle = await SELECT.one
            .from('fleet.Vehicles')
            .columns('Odometer')
            .where({ ID: Vehicle_ID });

        if (vehicle && vehicle.Odometer) {
            const efficiency = computeFuelEfficiency(Odometer, vehicle.Odometer, Liters);
            if (efficiency !== null) {
                req.data.FuelEfficiency = efficiency;
            }
        }

        // Auto-calculate TotalCost if not provided
        if (!req.data.TotalCost && req.data.CostPerLiter) {
            req.data.TotalCost = parseFloat(
                (Liters * req.data.CostPerLiter).toFixed(2)
            );
        }
    });




    this.after('CREATE', ServiceRecords, async (data) => {

        if (!data || !data.Vehicle_ID) return;
        await _postServiceCleanup(data.Vehicle_ID, data.NextServiceOdometer);
    });



    this.on('logService', 'ServiceRecords', async (req) => {

        try {

            const { ID } =
                req.params[0];

            const serviceRecord =
                await SELECT.one
                    .from('MaintenanceService.ServiceRecords')
                    .where({ ID });

            console.log(serviceRecord);

            console.log(
                `Logging service for record ID: ${ID}`
            );

            req.info(`

Custom logService action triggered


Record ID          : ${serviceRecord.ID}

Vehicle ID         : ${serviceRecord.Vehicle_ID}

Service Type       : ${serviceRecord.ServiceType}

Service Date       : ${serviceRecord.ServiceDate}

Service Center     : ${serviceRecord.ServiceCenter}

Odometer           : ${serviceRecord.Odometer}

Cost               : ₹${serviceRecord.Cost}

Description        : ${serviceRecord.Description}

Next Service KM    : ${serviceRecord.NextServiceOdometer}

`);

            return {
                success: true,
                message:
                    `Service logged successfully for record ${ID}.`,
                data: serviceRecord
            };

        } catch (error) {

            req.error(
                500,
                `Failed to log service: ${error.message}`
            );
        }
    });

    


    // =========================================================================
    //  Private Helper : post-service cleanup
    // =========================================================================
    /**
     * Shared logic executed both after the draft-activate path and after
     * the logService action.
     *
     * @param {string} vehicleID
     * @param {number|null} nextServiceOdometer
     */
    async function _postServiceCleanup(vehicleID, nextServiceOdometer) {
        // 1. Update vehicle's next service schedule
        const updatePayload = {
            NextServiceDue: addMonths(6)  // next service due 6 months from today
        };
        if (nextServiceOdometer) {
            updatePayload.NextServiceOdometer = nextServiceOdometer;
        }
        await UPDATE('fleet.Vehicles', vehicleID).with(updatePayload);

        // 2. Auto-close all open alerts for this vehicle
        await UPDATE(MaintenanceAlerts)
            .set({ Status: 'Closed' })
            .where({ Vehicle_ID: vehicleID, Status: { '!=': 'Closed' } });
    }

});

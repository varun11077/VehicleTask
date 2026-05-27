// =============================================================================
//  srv/fleet-service.js
//  Handler implementation for FleetService
//
//  Registers:
//    AFTER  READ     Vehicles          — populate StatusCriticality (virtual)
//    AFTER  READ     MaintenanceAlerts — populate AlertCriticality  (virtual)
//    ON     assignVehicle              — validate + assign vehicle to employee
//    ON     releaseVehicle             — release assignment, set status Available
//    ON     updateOdometer             — record reading; auto-create alert if due
//    ON     getVehiclesDueForService   — query overdue vehicles
// =============================================================================
'use strict';

const cds = require('@sap/cds');
const {
    validateVehicle,
    validateEmployeeForDriving,
    vehicleStatusCriticality,
    alertStatusCriticality
} = require('./utils/validators');
const { SELECT } = require('@sap/cds/lib/ql/cds-ql');

module.exports = cds.service.impl(async function () {

    const { Vehicles, Employees, MaintenanceAlerts } = this.entities;

    /**
     * Handler for the bound 'closeAlert' action on MaintenanceAlerts
     */
      this.on('closeAlert',MaintenanceAlerts, async (req) => {
            console.log("ACTION TRIGGERED");
            const alertId = req.params[1].ID;
            const alert = await SELECT.one.from(MaintenanceAlerts).where({ID:alertId})
            if(!alert) req.reject(400,"No alert found with this ID")
            console.log(alert)

            if(alert.Status == 'Closed') req.reject(400,"Alert already Closed")

            await UPDATE(MaintenanceAlerts)
                .set({
                    Status: 'Closed'
                })
                .where({
                    ID: alertId
                });
            req.notify("Alert closed successfully")
            return {
                success: true,
                message: `Alert ${alertId} closed successfully`
            };

    });

    
    this.after('READ', Vehicles, (results) => {
        const rows = Array.isArray(results) ? results : [results];
        for (const row of rows) {
            if (row && row.Status !== undefined) {
                row.StatusCriticality = vehicleStatusCriticality(row.Status);
            }
        }
    });

    
    this.after('READ', MaintenanceAlerts, (results) => {
        const rows = Array.isArray(results) ? results : [results];
        for (const row of rows) {
            if (row && row.Status !== undefined) {
                row.AlertCriticality = alertStatusCriticality(row.Status);
            }
        }
    });


   
    this.on('assignVehicle', async (req) => {
        const { vehicleID, employeeID } = req.data;

       
        const vResult = await validateVehicle(Vehicles, vehicleID, 'Available');
        if (!vResult.valid) return req.error(400, vResult.error);

        
        const eResult = await validateEmployeeForDriving(Employees, employeeID);
        if (!eResult.valid) return req.error(400, eResult.error);

        
        await UPDATE(Vehicles, vehicleID).with({
            Status: 'Assigned',
            AssignedTo_ID: employeeID
        });

        return {
            success: true,
            message: `Vehicle '${vResult.vehicle.RegNumber}' successfully assigned ` +
                `to ${eResult.employee.Name}.`
        };
    });


   
    this.on('releaseVehicle', async (req) => {
        const { vehicleID } = req.data;

        const vResult = await validateVehicle(Vehicles, vehicleID);
        if (!vResult.valid) return req.error(404, vResult.error);

        const vehicle = vResult.vehicle;
        if (vehicle.Status === 'Retired') {
            return req.error(400,
                `Vehicle '${vehicle.RegNumber}' is retired and cannot be released.`);
        }

        await UPDATE(Vehicles, vehicleID).with({
            Status: 'Available',
            AssignedTo_ID: null
        });

        return {
            success: true,
            message: `Vehicle '${vehicle.RegNumber}' released and now Available.`
        };
    });


    this.on('updateOdometer', async (req) => {
        const { vehicleID, newReading } = req.data;

        const vResult = await validateVehicle(Vehicles, vehicleID);
        if (!vResult.valid) return req.error(404, vResult.error);

        const vehicle = vResult.vehicle;

        if (newReading <= vehicle.Odometer) {
            return req.error(400,
                `New reading (${newReading} km) must be greater than ` +
                `current odometer (${vehicle.Odometer} km).`);
        }

        // Persist new odometer
        await UPDATE(Vehicles, vehicleID).with({ Odometer: newReading });

        // Check if maintenance is now due by mileage
        let alertCreated = false;
        if (vehicle.NextServiceOdometer &&
            newReading >= vehicle.NextServiceOdometer) {

            await INSERT.into(MaintenanceAlerts).entries({
                ID: cds.utils.uuid(),
                Vehicle_ID: vehicleID,
                AlertType: 'MileageDue',
                DueDate: vehicle.NextServiceDue ?? null,
                DueOdometer: vehicle.NextServiceOdometer,
                Status: 'Open',
                CreatedAt: new Date().toISOString(),
                Description: `Vehicle '${vehicle.RegNumber}' has reached the ` +
                    `service mileage threshold of ${vehicle.NextServiceOdometer} km.`
            });

            alertCreated = true;
        }

        return {
            success: true,
            message: `Odometer updated to ${newReading} km.` +
                (alertCreated ? ' A maintenance alert has been raised.' : ''),
            alertCreated
        };
    });


    
    this.on('getVehiclesDueForService', async (req) => {
        const today = new Date().toISOString().split('T')[0];

        const overdue = await SELECT.from(Vehicles).where(
            `NextServiceDue <= '${today}'` +
            ` OR (NextServiceOdometer IS NOT NULL AND Odometer >= NextServiceOdometer)`
        );

        // Populate criticality for the returned set
        overdue.forEach(v => {
            v.StatusCriticality = vehicleStatusCriticality(v.Status);
        });
req.info({
    message: `${overdue.length} vehicles due for service`,
    numericSeverity: 2
});
        return overdue;
    });

});

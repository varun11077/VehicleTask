




// =============================================================================
//  srv/utils/validators.js
//  Shared validation helpers for FleetService and MaintenanceService handlers.
//
//  All functions return a result object { valid, data, error } so callers
//  can decide how to surface failures (req.error vs throw).
// =============================================================================
'use strict';

// ---------------------------------------------------------------------------
//  Vehicle Validators
// ---------------------------------------------------------------------------

/**
 * Asserts a vehicle exists and optionally has the expected status.
 *
 * @param {object}      Vehicles       — CDS entity from the current service
 * @param {string}      vehicleID      — UUID to look up
 * @param {string|null} expectedStatus — Required status value (or null)
 * @returns {{ valid:boolean, vehicle:object|null, error:string|null }}
 */
async function validateVehicle(Vehicles, vehicleID, expectedStatus = null) {
    const vehicle = await SELECT.one.from(Vehicles).where({ ID: vehicleID });

    if (!vehicle) {
        return {
            valid:   false,
            vehicle: null,
            error:   `Vehicle '${vehicleID}' was not found.`
        };
    }

    if (expectedStatus && vehicle.Status !== expectedStatus) {
        return {
            valid:   false,
            vehicle,
            error:   `Vehicle '${vehicle.RegNumber}' must be '${expectedStatus}' ` +
                     `but is currently '${vehicle.Status}'.`
        };
    }

    return { valid: true, vehicle, error: null };
}


// ---------------------------------------------------------------------------
//  Employee / Driver Validators
// ---------------------------------------------------------------------------

/**
 * Asserts an employee exists and holds a valid, non-expired driver license.
 *
 * @param {object} Employees   — CDS entity from the current service
 * @param {string} employeeID  — UUID to look up
 * @returns {{ valid:boolean, employee:object|null, error:string|null }}
 */
async function validateEmployeeForDriving(Employees, employeeID) {
    const employee = await SELECT.one.from(Employees).where({ ID: employeeID });

    if (!employee) {
        return {
            valid:    false,
            employee: null,
            error:    `Employee '${employeeID}' was not found.`
        };
    }

    if (!employee.DriverLicense) {
        return {
            valid:    false,
            employee,
            error:    `Employee '${employee.Name}' has no driver license on file.`
        };
    }

    if (!employee.LicenseExpiry) {
        return {
            valid:    false,
            employee,
            error:    `Employee '${employee.Name}' has no license expiry date recorded.`
        };
    }

    // Compare expiry against today at midnight (UTC)
    const today      = new Date();
    today.setUTCHours(0, 0, 0, 0);
    const expiryDate = new Date(employee.LicenseExpiry);

    if (expiryDate <= today) {
        return {
            valid:    false,
            employee,
            error:    `Employee '${employee.Name}' driver license expired on ` +
                      `${employee.LicenseExpiry}. Renewal required before assignment.`
        };
    }

    return { valid: true, employee, error: null };
}


// ---------------------------------------------------------------------------
//  Business Calculation Helpers
// ---------------------------------------------------------------------------

/**
 * Compute fuel efficiency in km per litre.
 *
 * Formula:  (currentOdometer − previousOdometer) / litresFilled
 *
 * @param {number} currentOdometer  — reading at fill-up
 * @param {number} previousOdometer — vehicle's odometer before this fill-up
 * @param {number} litres           — litres of fuel added
 * @returns {number|null}           — km/L (2 dp) or null if inputs invalid
 */
function computeFuelEfficiency(currentOdometer, previousOdometer, litres) {
    if (!currentOdometer || !previousOdometer || !litres) return null;
    if (currentOdometer <= previousOdometer) return null;
    if (litres <= 0) return null;
    return parseFloat(((currentOdometer - previousOdometer) / litres).toFixed(2));
}

/**
 * Map a VehicleStatus value to a Fiori Elements criticality integer.
 *
 *  3 = Positive  (green)  — Available
 *  0 = Neutral   (grey)   — Assigned
 *  2 = Critical  (orange) — UnderMaintenance
 *  1 = Negative  (red)    — Retired
 */
function vehicleStatusCriticality(status) {
    const map = {
        Available:        3,
        Assigned:         0,
        UnderMaintenance: 2,
        Retired:          1
    };
    return map[status] ?? 0;
}

/**
 * Map an AlertStatus value to a Fiori Elements criticality integer.
 *
 *  1 = Negative  (red)    — Open
 *  2 = Critical  (orange) — Acknowledged
 *  3 = Positive  (green)  — Closed
 */
function alertStatusCriticality(status) {
    const map = {
        Open:         1,
        Acknowledged: 2,
        Closed:       3
    };
    return map[status] ?? 0;
}

/**
 * Return ISO date string for today + N calendar months.
 * Used to calculate the next scheduled service date after logging a service.
 */
function addMonths(months = 6) {
    const d = new Date();
    d.setMonth(d.getMonth() + months);
    return d.toISOString().split('T')[0];
}

module.exports = {
    validateVehicle,
    validateEmployeeForDriving,
    computeFuelEfficiency,
    vehicleStatusCriticality,
    alertStatusCriticality,
    addMonths
};

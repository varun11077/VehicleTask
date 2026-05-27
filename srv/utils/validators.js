
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



function computeFuelEfficiency(currentOdometer, previousOdometer, litres) {
    if (!currentOdometer || !previousOdometer || !litres) return null;
    if (currentOdometer <= previousOdometer) return null;
    if (litres <= 0) return null;
    return parseFloat(((currentOdometer - previousOdometer) / litres).toFixed(2));
}


function vehicleStatusCriticality(status) {
    const map = {
        Available:        3,
        Assigned:         0,
        UnderMaintenance: 2,
        Retired:          1
    };
    return map[status] ?? 0;
}


function alertStatusCriticality(status) {
    const map = {
        Open:         1,
        Acknowledged: 2,
        Closed:       3
    };
    return map[status] ?? 0;
}


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

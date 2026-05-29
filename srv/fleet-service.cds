using { fleet } from '../db/schema';

service FleetService @(requires: 'authenticated-user') {

    @restrict: [
        { grant: 'READ', to: ['Fleet.Read', 'Fleet.Assign', 'Fleet.Manage', 'Admin.All'] },
        { grant: ['CREATE', 'UPDATE', 'DELETE'], to: ['Fleet.Manage', 'Admin.All'] }
    ]
    entity Vehicles as projection on fleet.Vehicles 
    actions {

        @restrict: [
            { grant: 'EXECUTE', to: ['Fleet.Assign', 'Fleet.Manage', 'Admin.All'] }
        ]
        action assignVehicle(
    @(  title : 'Select Driver',
        Common : {
            ValueListWithFixedValues : false, // False forces a searchable pop-up instead of a flat dropdown
            ValueList : {
                Label           : 'Drivers List',
                CollectionPath  : 'Employees',
                Parameters      : [
                    {
                        $Type            : 'Common.ValueListParameterInOut',
                        ValueListProperty: 'ID', // The field from Employees entity
                        LocalDataProperty: employeeID // The parameter name in this action
                    },
                    {
                        $Type            : 'Common.ValueListParameterDisplayOnly',
                        ValueListProperty: 'Name' // Shows the driver's name in the popup grid
                    },
                    {
                        $Type            : 'Common.ValueListParameterDisplayOnly',
                        ValueListProperty: 'Email' // Shows their email to help differentiate drivers
                    }
                ]
            }
        }
    )
    employeeID: Employees:ID
) returns {
    success : Boolean;
    message : String;
};

        @restrict: [
            { grant: 'EXECUTE', to: ['Fleet.Assign', 'Fleet.Manage', 'Admin.All'] }
        ]
        action releaseVehicle(
        ) returns {
            success : Boolean;
            message : String;
        };

        @restrict: [
            { grant: 'EXECUTE', to: ['Fleet.Manage', 'Admin.All'] }
        ]
        action updateOdometer(
            vehicleID  : UUID,
            newReading : Decimal
        ) returns {
            success      : Boolean;
            message      : String;
            alertCreated : Boolean;
        };


        @restrict: [
            { grant: 'EXECUTE', to: ['Fleet.Manage', 'Admin.All'] }
        ]
        function getVehiclesDueForService() returns array of Vehicles;
    };


    @restrict: [
        { grant: 'READ', to: ['Fleet.Read', 'Fleet.Assign', 'Fleet.Manage', 'Admin.All'] },
        { grant: ['CREATE', 'UPDATE'], to: ['Fleet.Manage', 'Admin.All'] }
    ]
    entity Employees as projection on fleet.Employees {

        *,

        vehicles : redirected to Vehicles
    };


    @readonly
    @restrict: [
        { grant: 'READ', to: ['Fleet.Read', 'Fleet.Assign', 'Fleet.Manage', 'Maintenance.Manage', 'Admin.All'] }
    ]
    entity ServiceRecords as projection on fleet.ServiceRecords {

        *,

        Vehicle : redirected to Vehicles
    };


    @readonly
    @restrict: [
        { grant: 'READ', to: ['Fleet.Read', 'Fleet.Manage', 'Admin.All'] }
    ]
    entity FuelLogs as projection on fleet.FuelLogs {

        *,

        Vehicle : redirected to Vehicles,
        Driver  : redirected to Employees
    };


    @restrict: [
        { grant: 'READ', to: ['Fleet.Manage', 'Admin.All'] },
        { grant: ['CREATE', 'UPDATE'], to: ['Fleet.Manage', 'Admin.All'] }
    ]
    entity MaintenanceAlerts as projection on fleet.MaintenanceAlerts {

        *,

        Vehicle : redirected to Vehicles
    }actions{
            action closeAlert() returns {
            success : Boolean;
            message : String;
        };
    }
}
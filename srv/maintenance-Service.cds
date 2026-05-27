using {fleet} from '../db/schema';

@path: '/maintenance'
service MaintenanceService @(requires: 'authenticated-user') {



@odata.draft.enabled
@restrict: [
    {
        grant: 'READ',
        to   : [
            'Maintenance.Manage',
            'Fleet.Manage',
            'Admin.All'
        ]
    },
    {
        grant: [
            'CREATE',
            'UPDATE'
        ],
        to   : [
            'Maintenance.Manage',
            'Admin.All'
        ]
    }
]
entity ServiceRecords    as projection on fleet.ServiceRecords
    actions {

        // This annotation explicitly binds the action to the single row instance
        @cds.odata.bindingpath: ' _it'
        action logService() returns {
            success : Boolean;
            message : String;
        };
        

    };


@restrict: [
    {
        grant: 'READ',
        to   : [
            'Maintenance.Log',
            'Maintenance.Manage',
            'Fleet.Manage',
            'Admin.All'
        ]
    },
    {
        grant: ['CREATE'],
        to   : [
            'Maintenance.Log',
            'Maintenance.Manage',
            'Admin.All'
        ]
    }
]
entity FuelLogs          as projection on fleet.FuelLogs;


@restrict: [
    {
        grant: 'READ',
        to   : [
            'Maintenance.Manage',
            'Fleet.Manage',
            'Admin.All'
        ]
    },
    {
        grant: ['UPDATE'],
        to   : [
            'Maintenance.Manage',
            'Admin.All'
        ]
    }
]
entity MaintenanceAlerts as projection on fleet.MaintenanceAlerts;



@readonly
entity Vehicles          as projection on fleet.Vehicles;


@readonly
entity Employees         as projection on fleet.Employees;



}


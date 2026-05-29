using {fleet} from '../db/schema';

// @path: '/maintenance'
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
        @restrict: [
            {
                grant: '*',
                to   : [
                    'Maintenance.Manage',
                    'Admin.All'
                ]
            }
        ]
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



// @readonly
// @Analytics.query: true
// @Aggregation.ApplySupported: {
//     Transformations       : ['aggregate', 'groupby', 'filter', 'orderby', 'top', 'skip', 'search'],
//     Rollup                : #None,
//     PropertyRestrictions  : true,
//     GroupableProperties   : [CostCategory, CostDate, Vehicle_ID],
//     AggregatableProperties: [
//         { Property: TotalCost   },
//         { Property: ServiceCost },
//         { Property: FuelCost    },
//         { Property: costCount   }
//     ]
// }
// @Analytics.AggregatedProperty #totalCost: {
//     Name                : 'totalCost',
//     AggregationMethod   : 'sum',
//     AggregatableProperty: 'TotalCost',
//     ![@Common.Label]    : 'Total Fleet Cost'
// }
// @Analytics.AggregatedProperty #totalServiceCost: {
//     Name                : 'totalServiceCost',
//     AggregationMethod   : 'sum',
//     AggregatableProperty: 'ServiceCost',
//     ![@Common.Label]    : 'Total Service Cost'
// }
// @Analytics.AggregatedProperty #totalFuelCost: {
//     Name                : 'totalFuelCost',
//     AggregationMethod   : 'sum',
//     AggregatableProperty: 'FuelCost',
//     ![@Common.Label]    : 'Total Fuel Cost'
// }
// @Analytics.AggregatedProperty #totalRecords: {
//     Name                : 'totalRecords',
//     AggregationMethod   : 'sum',
//     AggregatableProperty: 'costCount',
//     ![@Common.Label]    : 'Cost Entries'
// }
// entity CostKPIs as projection on fleet.CostKPIs;
}
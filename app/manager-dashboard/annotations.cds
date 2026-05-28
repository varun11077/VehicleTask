using MaintenanceService as service from '../../srv/maintenance-Service';

annotate service.ServiceRecords with {
    Vehicle             @title: 'Vehicle';
    ServiceType         @title: 'Service Type';
    ServiceDate         @title: 'Service Date';
    ServiceCenter       @title: 'Service Center';
    Odometer            @title: 'Odometer at Service (km)';
    Cost                @title: 'Cost (₹)';
    Description         @title: 'Description';
    NextServiceOdometer @title: 'Next Service at (km)';
}

annotate service.ServiceRecords with {
    ServiceType @Common.ValueListWithFixedValues: true;
}

annotate service.ServiceRecords with {
    Vehicle @(
        Common.ValueList               : {
            CollectionPath: 'Vehicles',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterOut',
                    LocalDataProperty: Vehicle_ID,
                    ValueListProperty: 'ID'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'RegNumber'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'Make'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'Model'
                }
            ]
        },
        Common.ValueListWithFixedValues: false
    )
}

annotate service.ServiceRecords with @(

    UI.SelectionFields: [
        Vehicle_ID,
        ServiceType,
        ServiceDate
    ],

    UI.LineItem       : [
        {
            $Type: 'UI.DataField',
            Value: Vehicle.RegNumber,
            Label: 'Vehicle'
        },
        {
            $Type: 'UI.DataField',
            Value: ServiceType,
            Label: 'Service Type'
        },
        {
            $Type: 'UI.DataField',
            Value: ServiceDate,
            Label: 'Service Date'
        },
        {
            $Type: 'UI.DataField',
            Value: ServiceCenter,
            Label: 'Service Center'
        },
        {
            $Type: 'UI.DataField',
            Value: Odometer,
            Label: 'Odometer (km)'
        },
        {
            $Type: 'UI.DataField',
            Value: Cost,
            Label: 'Cost (₹)'
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'MaintenanceService.logService',
            Label : 'Log Service',
        },]

);

annotate service.ServiceRecords with @(

    UI.HeaderInfo                : {
        TypeName      : 'Service Record',
        TypeNamePlural: 'Service Records',
        Title         : {
            $Type: 'UI.DataField',
            Value: ServiceType
        },
        Description   : {
            $Type: 'UI.DataField',
            Value: Vehicle.RegNumber
        }
    },

    UI.Identification            : [
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'MaintenanceService.logService',
            Label : 'Log Service',
        },

    ],

    UI.Facets                    : [
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'ServiceDetailFacet',
            Label : 'Service Details',
            Target: '@UI.FieldGroup#ServiceDetails'
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'CostFacet',
            Label : 'Cost & Schedule',
            Target: '@UI.FieldGroup#CostSchedule'
        }
    ],

    UI.FieldGroup #ServiceDetails: {
        $Type: 'UI.FieldGroupType',
        Label: 'Service Details',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: Vehicle_ID,
                Label: 'Vehicle'
            },
            {
                $Type: 'UI.DataField',
                Value: ServiceType,
                Label: 'Service Type'
            },
            {
                $Type: 'UI.DataField',
                Value: ServiceDate,
                Label: 'Service Date'
            },
            {
                $Type: 'UI.DataField',
                Value: ServiceCenter,
                Label: 'Service Center'
            },
            {
                $Type: 'UI.DataField',
                Value: Odometer,
                Label: 'Odometer at Service (km)'
            },
            {
                $Type: 'UI.DataField',
                Value: Description,
                Label: 'Description'
            }
        ]
    },

    UI.FieldGroup #CostSchedule  : {
        $Type: 'UI.FieldGroupType',
        Label: 'Cost & Next Service',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: Cost,
                Label: 'Service Cost (₹)'
            },
            {
                $Type: 'UI.DataField',
                Value: NextServiceOdometer,
                Label: 'Next Service at (km)'
            }
        ]
    }
);


annotate service.FuelLogs with {
    Vehicle        @title: 'Vehicle';
    Driver         @title: 'Driver';
    FuelDate       @title: 'Fill-up Date';
    Liters         @title: 'Litres';
    CostPerLiter   @title: 'Cost per Litre (₹)';
    TotalCost      @title: 'Total Cost (₹)';
    Odometer       @title: 'Odometer at Fill-up (km)';
    FuelEfficiency @title: 'Fuel Efficiency (km/L)';


}


annotate service.FuelLogs with {
    Vehicle @(
        Common.ValueList               : {
            CollectionPath: 'Vehicles',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterOut',
                    LocalDataProperty: Vehicle_ID,
                    ValueListProperty: 'ID'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'RegNumber'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'Make'
                }
            ]
        },
        Common.ValueListWithFixedValues: false
    );
    Driver  @(
        Common.ValueList               : {
            CollectionPath: 'Employees',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterOut',
                    LocalDataProperty: Driver_ID,
                    ValueListProperty: 'ID'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'Name'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'EmployeeID'
                }
            ]
        },
        Common.ValueListWithFixedValues: false
    )
}

annotate service.FuelLogs with @(

    UI.SelectionFields: [
        Vehicle_ID,
        Driver_ID,
        FuelDate
    ],

    UI.LineItem       : [
        {
            $Type: 'UI.DataField',
            Value: Vehicle.RegNumber,
            Label: 'Vehicle'
        },
        {
            $Type: 'UI.DataField',
            Value: Driver.Name,
            Label: 'Driver'
        },
        {
            $Type: 'UI.DataField',
            Value: FuelDate,
            Label: 'Date'
        },
        {
            $Type: 'UI.DataField',
            Value: Liters,
            Label: 'Litres'
        },
        {
            $Type: 'UI.DataField',
            Value: CostPerLiter,
            Label: 'Cost/Litre (₹)'
        },
        {
            $Type: 'UI.DataField',
            Value: TotalCost,
            Label: 'Total Cost (₹)'
        },
        {
            $Type: 'UI.DataField',
            Value: Odometer,
            Label: 'Odometer (km)'
        },
        {
            $Type: 'UI.DataField',
            Value: FuelEfficiency,
            Label: 'Efficiency (km/L)'
        }
    ]
);

annotate service.FuelLogs with @(

    UI.HeaderInfo             : {
        TypeName      : 'Fuel Log',
        TypeNamePlural: 'Fuel Logs',
        Title         : {
            $Type: 'UI.DataField',
            Value: Vehicle.RegNumber
        },
        Description   : {
            $Type: 'UI.DataField',
            Value: FuelDate
        }
    },

    UI.Facets                 : [{
        $Type : 'UI.ReferenceFacet',
        ID    : 'FuelDetailFacet',
        Label : 'Fuel Log Details',
        Target: '@UI.FieldGroup#FuelDetails'
    }],

    UI.FieldGroup #FuelDetails: {
        $Type: 'UI.FieldGroupType',
        Label: 'Fill-up Information',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: Vehicle_ID,
                Label: 'Vehicle'
            },
            {
                $Type: 'UI.DataField',
                Value: Driver_ID,
                Label: 'Driver'
            },
            {
                $Type: 'UI.DataField',
                Value: FuelDate,
                Label: 'Fill-up Date'
            },
            {
                $Type: 'UI.DataField',
                Value: Liters,
                Label: 'Litres Filled'
            },
            {
                $Type: 'UI.DataField',
                Value: CostPerLiter,
                Label: 'Cost per Litre (₹)'
            },
            {
                $Type: 'UI.DataField',
                Value: TotalCost,
                Label: 'Total Cost (₹)'
            },
            {
                $Type: 'UI.DataField',
                Value: Odometer,
                Label: 'Odometer at Fill-up (km)'
            },
            {
                $Type: 'UI.DataField',
                Value: FuelEfficiency,
                Label: 'Fuel Efficiency (km/L)'
            }
        ]
    }
);


annotate service.MaintenanceAlerts with {
    Vehicle     @title: 'Vehicle';
    AlertType   @title: 'Alert Type';
    DueDate     @title: 'Due Date';
    DueOdometer @title: 'Due at (km)';
    Status      @title: 'Status';
    CreatedAt   @title: 'Raised On';
    Description @title: 'Description';
}

annotate service.MaintenanceAlerts with {
    AlertType @Common.ValueListWithFixedValues: true;
    Status    @Common.ValueListWithFixedValues: true;
}

annotate service.MaintenanceAlerts with {
    Vehicle @(
        Common.ValueList               : {
            CollectionPath: 'Vehicles',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterOut',
                    LocalDataProperty: Vehicle_ID,
                    ValueListProperty: 'ID'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'RegNumber'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'Make'
                }
            ]
        },
        Common.ValueListWithFixedValues: false
    )
}

annotate service.MaintenanceAlerts with @(

    UI.SelectionFields: [
        Status,
        AlertType,
        Vehicle_ID
    ],

    UI.LineItem       : [
        {
            $Type: 'UI.DataField',
            Value: Vehicle.RegNumber,
            Label: 'Vehicle'
        },
        {
            $Type: 'UI.DataField',
            Value: AlertType,
            Label: 'Alert Type'
        },
        {
            $Type: 'UI.DataField',
            Value: DueDate,
            Label: 'Due Date'
        },
        {
            $Type: 'UI.DataField',
            Value: DueOdometer,
            Label: 'Due at (km)'
        },
        {
            $Type                    : 'UI.DataField',
            Value                    : Status,
            Label                    : 'Status',
            Criticality              : AlertCriticality,
            CriticalityRepresentation: #WithIcon
        },
        {
            $Type: 'UI.DataField',
            Value: CreatedAt,
            Label: 'Raised On'
        },
        {
            $Type: 'UI.DataField',
            Value: Description,
            Label: 'Description'
        },


    ]
);

annotate service.MaintenanceAlerts with @(

    UI.HeaderInfo              : {
        TypeName      : 'Maintenance Alert',
        TypeNamePlural: 'Maintenance Alerts',
        Title         : {
            $Type: 'UI.DataField',
            Value: AlertType
        },
        Description   : {
            $Type: 'UI.DataField',
            Value: Vehicle.RegNumber
        }
    },

    UI.DataPoint #AlertStatus  : {
        Value      : Status,
        Title      : 'Alert Status',
        Criticality: AlertCriticality
    },

    UI.HeaderFacets            : [{
        $Type : 'UI.ReferenceFacet',
        Target: '@UI.DataPoint#AlertStatus',
        Label : 'Status'
    }],


    UI.Facets                  : [{
        $Type : 'UI.ReferenceFacet',
        ID    : 'AlertDetailFacet',
        Label : 'Alert Details',
        Target: '@UI.FieldGroup#AlertDetails'
    }],

    UI.FieldGroup #AlertDetails: {
        $Type: 'UI.FieldGroupType',
        Label: 'Alert Information',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: Vehicle_ID,
                Label: 'Vehicle'
            },
            {
                $Type: 'UI.DataField',
                Value: AlertType,
                Label: 'Alert Type'
            },
            {
                $Type: 'UI.DataField',
                Value: DueDate,
                Label: 'Due Date'
            },
            {
                $Type: 'UI.DataField',
                Value: DueOdometer,
                Label: 'Due at (km)'
            },
            {
                $Type                    : 'UI.DataField',
                Value                    : Status,
                Label                    : 'Status',
                Criticality              : AlertCriticality,
                CriticalityRepresentation: #WithIcon
            },
            {
                $Type: 'UI.DataField',
                Value: CreatedAt,
                Label: 'Raised On'
            },
            {
                $Type: 'UI.DataField',
                Value: Description,
                Label: 'Description'
            }
        ]
    }
);



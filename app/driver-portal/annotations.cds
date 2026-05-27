using FleetService as service from '../../srv/fleet-service';

annotate service.Vehicles with {
    RegNumber           @title: 'Registration Number';
    Make                @title: 'Make';
    Model               @title: 'Model';
    Year                @title: 'Year';
    FuelType            @title: 'Fuel Type';
    Status              @title: 'Status';
    AssignedTo          @title: 'Assigned Driver';
    Odometer            @title: 'Current Odometer (km)';
    NextServiceDue      @title: 'Next Service Due Date';
    NextServiceOdometer @title: 'Next Service at (km)';
}

annotate service.Vehicles with {
    FuelType @Common.ValueListWithFixedValues: true;
    Status   @Common.ValueListWithFixedValues: true;
}

annotate service.Vehicles with {
    AssignedTo @(
        Common.ValueList               : {
            CollectionPath: 'Employees',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterOut',
                    LocalDataProperty: AssignedTo_ID,
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

annotate service.Vehicles with @(

    UI.SelectionFields: [
        Status,
        FuelType,
        AssignedTo_ID
    ],

    UI.LineItem       : [
        {
            $Type: 'UI.DataField',
            Value: RegNumber,
            Label: 'Reg Number'
        },
        {
            $Type: 'UI.DataField',
            Value: Make,
            Label: 'Make'
        },
        {
            $Type: 'UI.DataField',
            Value: Model,
            Label: 'Model'
        },
        {
            $Type: 'UI.DataField',
            Value: Year,
            Label: 'Year'
        },
        {
            $Type: 'UI.DataField',
            Value: FuelType,
            Label: 'Fuel Type'
        },
        {
            $Type                    : 'UI.DataField',
            Value                    : Status,
            Label                    : 'Status',
            Criticality              : VehicleCriticality,
            CriticalityRepresentation: #WithIcon
        },
        {
            $Type: 'UI.DataField',
            Value: AssignedTo.Name,
            Label: 'Assigned To'
        },
        {
            $Type: 'UI.DataField',
            Value: Odometer,
            Label: 'Odometer (km)'
        },
        {
            $Type: 'UI.DataField',
            Value: NextServiceDue,
            Label: 'Next Service Due'
        },
        {
            $Type      : 'UI.DataFieldForAction',
            Action     : 'FleetService.assignVehicle',
            Label      : 'Assign Vehicle',
        },
        {
            $Type      : 'UI.DataFieldForAction',
            Action     : 'FleetService.releaseVehicle',
            Label      : 'Release Vehicle',

        },
        {
            $Type      : 'UI.DataFieldForAction',
            Action     : 'FleetService.updateOdometer',
            Label      : 'Update Odometer',
        }
    ]
);

annotate service.Vehicles with @(

    UI.HeaderInfo                 : {
        TypeName      : 'Vehicle',
        TypeNamePlural: 'Vehicles',
        Title         : {
            $Type: 'UI.DataField',
            Value: RegNumber
        },
        Description   : {
            $Type: 'UI.DataField',
            Value: Make
        }
    },

    UI.DataPoint #VehicleStatus   : {
        Value      : Status,
        Title      : 'Vehicle Status',
        Criticality: VehicleCriticality
    },

    UI.DataPoint #OdometerReading : {
        Value: Odometer,
        Title: 'Odometer (km)'
    },

    UI.DataPoint #NextService     : {
        Value: NextServiceDue,
        Title: 'Next Service Due'
    },

    UI.HeaderFacets               : [
        {
            $Type : 'UI.ReferenceFacet',
            Target: '@UI.DataPoint#VehicleStatus',
            Label : 'Status'
        },
        {
            $Type : 'UI.ReferenceFacet',
            Target: '@UI.DataPoint#OdometerReading',
            Label : 'Odometer'
        },
        {
            $Type : 'UI.ReferenceFacet',
            Target: '@UI.DataPoint#NextService',
            Label : 'Next Service'
        }
    ],

    UI.Identification             : [
        {
            $Type      : 'UI.DataFieldForAction',
            Action     : 'FleetService.assignVehicle',
            Label      : 'Assign Vehicle',
        },
        {
            $Type      : 'UI.DataFieldForAction',
            Action     : 'FleetService.releaseVehicle',
            Label      : 'Release Vehicle',
        },
        {
            $Type      : 'UI.DataFieldForAction',
            Action     : 'FleetService.updateOdometer',
            Label      : 'Update Odometer',
        },
        {
            $Type      : 'UI.DataFieldForAction',
            Action     : 'FleetService.getVehiclesDueForService',
            Label      : 'Due for Service',
        }
    ],

    UI.Facets                     : [
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'VehicleDetailFacet',
            Label : 'Vehicle Details',
            Target: '@UI.FieldGroup#VehicleDetails'
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'ServiceScheduleFacet',
            Label : 'Service Schedule',
            Target: '@UI.FieldGroup#ServiceSchedule'
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'ServiceRecordsFacet',
            Label : 'Service Records',
            Target: 'serviceRecords/@UI.LineItem'
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'FuelLogsFacet',
            Label : 'Fuel Logs',
            Target: 'fuelLogs/@UI.LineItem'
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'AlertsFacet',
            Label : 'Maintenance Alerts',
            Target: 'maintenanceAlerts/@UI.LineItem'
        }
    ],

    UI.FieldGroup #VehicleDetails : {
        $Type: 'UI.FieldGroupType',
        Label: 'Vehicle Information',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: RegNumber,
                Label: 'Registration Number'
            },
            {
                $Type: 'UI.DataField',
                Value: Make,
                Label: 'Make'
            },
            {
                $Type: 'UI.DataField',
                Value: Model,
                Label: 'Model'
            },
            {
                $Type: 'UI.DataField',
                Value: Year,
                Label: 'Year'
            },
            {
                $Type: 'UI.DataField',
                Value: FuelType,
                Label: 'Fuel Type'
            },
            {
                $Type                    : 'UI.DataField',
                Value                    : Status,
                Label                    : 'Status',
                Criticality              : VehicleCriticality,
                CriticalityRepresentation: #WithIcon
            },
            {
                $Type: 'UI.DataField',
                Value: AssignedTo_ID,
                Label: 'Assigned Driver'
            }
        ]
    },

    UI.FieldGroup #ServiceSchedule: {
        $Type: 'UI.FieldGroupType',
        Label: 'Odometer & Service Schedule',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: Odometer,
                Label: 'Current Odometer (km)'
            },
            {
                $Type: 'UI.DataField',
                Value: NextServiceDue,
                Label: 'Next Service Due Date'
            },
            {
                $Type: 'UI.DataField',
                Value: NextServiceOdometer,
                Label: 'Next Service at (km)'
            }
        ]
    }
);

// ─── ServiceRecords LineItem (needed for Vehicles sub-entity tab) ─────────────
annotate service.ServiceRecords with @(UI.LineItem: [
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
        $Type: 'UI.DataField',
        Value: Description,
        Label: 'Description'
    }
]);

// ─── FuelLogs LineItem (needed for Vehicles sub-entity tab) ──────────────────
annotate service.FuelLogs with @(UI.LineItem: [
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
]);

// ─── MaintenanceAlerts LineItem (needed for Vehicles sub-entity tab) ──────────
annotate service.MaintenanceAlerts with @(UI.LineItem: [
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
        Value: Description,
        Label: 'Description'
    },
    {
        $Type      : 'UI.DataFieldForAction',
        Action     : 'FleetService.MaintenanceAlerts/FleetService.closeAlert',
        Label      : 'Close Alert',
        Determining: true
    },
    {
        $Type : 'UI.DataFieldForAction',
        Action : 'FleetService.closeAlert',
        Label : 'Close Alert',
    },
],
    UI.Identification : [
        
    ],);

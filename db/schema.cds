namespace fleet;

using {cuid, managed} from '@sap/cds/common';

type FuelType      : String(20) @(assert.range) enum {
    Petrol;
    Diesel;
    Electric;
    Hybrid;
    CNG;
}

type VehicleStatus : String(25) @(assert.range) enum {
    Available;
    Assigned;
    UnderMaintenance;
    Retired;
}

type ServiceType   : String(30) @(assert.range) enum {
    OilChange;
    TireRotation;
    BrakeService;
    EngineCheck;
    GeneralService;
    Transmission;
    Electrical;
    Other;
}

type AlertType     : String(25) @(assert.range) enum {
    MileageDue;
    ScheduledService;
    LicenseExpiry;
    Other;
}

type AlertStatus   : String(15) @(assert.range) enum {
    Open;
    Acknowledged;
    Closed;
}

entity Employees : cuid {
    Name          : String(100) not null;
    Email         : String(150) not null;
    Department    : String(100);
    DriverLicense : String(50);
    LicenseExpiry : Date;
    vehicles      : Association to many Vehicles on vehicles.AssignedTo = $self;
                        
}
@odata.draft.enabled
entity Vehicles : cuid, managed {
    RegNumber                 : String(20) not null;
    Make                      : String(50) not null;
    Model                     : String(50) not null;
    Year                      : Integer;
    FuelType                  : FuelType;
    Status                    : VehicleStatus default 'Available';
    AssignedTo                : Association to Employees;
    Odometer                  : Decimal(10, 2) default 0;
    NextServiceDue            : Date;
    NextServiceOdometer       : Decimal(10, 2);
    virtual VehicleCriticality : Integer default 0;
    serviceRecords            : Association to many ServiceRecords on serviceRecords.Vehicle = $self;
    fuelLogs                  : Association to many FuelLogs on fuelLogs.Vehicle = $self;
                                    
    maintenanceAlerts         : Association to many MaintenanceAlerts on maintenanceAlerts.Vehicle = $self;
                                    
}
@odata.draft.enabled
entity ServiceRecords : cuid, managed {
    Vehicle             : Association to Vehicles not null;
    ServiceType         : ServiceType not null;
    ServiceDate         : Date not null;
    ServiceCenter       : String(150);
    Odometer            : Decimal(10, 2);
    Cost                : Decimal(12, 2);
    Description         : String(500);
    NextServiceOdometer : Decimal(10, 2);
    //alerts : Composition of MaintenanceAlerts on alerts.service=$self;
}
@odata.draft.enabled
entity FuelLogs : cuid {
    Vehicle        : Association to Vehicles not null;
    Driver         : Association to Employees;
    FuelDate       : Date not null;
    Liters         : Decimal(8, 2) not null;
    CostPerLiter   : Decimal(8, 3);
    TotalCost      : Decimal(10, 2);
    Odometer       : Decimal(10, 2);
    FuelEfficiency : Decimal(8, 2);
}

entity MaintenanceAlerts : cuid {
    Vehicle      : Association to Vehicles not null;
    AlertType    : String(30);
    DueDate      : Date;
    DueOdometer  : Decimal(10,2);
    Status       : String(20) default 'Open';
    CreatedAt    : Timestamp;
    Description  : String(300);
    virtual AlertCriticality : Integer default 0;
    //service : Association to ServiceRecords;
}



// db/schema.cds — replace your previous CostKPIs view with this

// @cds.autoexpose
// view CostKPIs as
//     select from ServiceRecords {
//         key ID,
//             Vehicle.ID          as Vehicle_ID   : UUID,
//             ServiceType         as CostCategory : String(50),
//             ServiceDate         as CostDate     : Date,
//             Cost                as TotalCost    : Decimal(12,2),
//             Cost                as ServiceCost  : Decimal(12,2),
//             0                   as FuelCost     : Decimal(10,2),
//             1                   as costCount    : Integer
//     }
//     union all
//     select from FuelLogs {
//         key ID,
//             Vehicle.ID          as Vehicle_ID   : UUID,
//             'Fuel'              as CostCategory : String(50),
//             FuelDate            as CostDate     : Date,
//             TotalCost           as TotalCost    : Decimal(12,2),
//             0                   as ServiceCost  : Decimal(12,2),
//             TotalCost           as FuelCost     : Decimal(10,2),
//             1                   as costCount    : Integer
//     };
 
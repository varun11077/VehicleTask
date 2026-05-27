sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"driverportal/test/integration/pages/VehiclesList",
	"driverportal/test/integration/pages/VehiclesObjectPage",
	"driverportal/test/integration/pages/FuelLogsObjectPage"
], function (JourneyRunner, VehiclesList, VehiclesObjectPage, FuelLogsObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('driverportal') + '/test/flp.html#app-preview',
        pages: {
			onTheVehiclesList: VehiclesList,
			onTheVehiclesObjectPage: VehiclesObjectPage,
			onTheFuelLogsObjectPage: FuelLogsObjectPage
        },
        async: true
    });

    return runner;
});


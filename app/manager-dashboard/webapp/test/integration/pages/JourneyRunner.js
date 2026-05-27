sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"managerdashboard/test/integration/pages/ServiceRecordsList",
	"managerdashboard/test/integration/pages/ServiceRecordsObjectPage"
], function (JourneyRunner, ServiceRecordsList, ServiceRecordsObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('managerdashboard') + '/test/flp.html#app-preview',
        pages: {
			onTheServiceRecordsList: ServiceRecordsList,
			onTheServiceRecordsObjectPage: ServiceRecordsObjectPage
        },
        async: true
    });

    return runner;
});


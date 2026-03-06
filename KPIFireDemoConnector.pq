[Version = "1.0.0"]
section KPIFireDemoConnector;

[DataSource.Kind="KPIFireDemoConnector", Publish="KPIFireDemoConnector.Publish"]
shared KPIFireDemoConnector.Contents = () =>
    let
        Source = GetKPIFireData()
    in
        Source;


// ================================
// Login + Fetch Data
// ================================

GetKPIFireData = () =>
    let
        credential = Extension.CurrentCredential(),
        username = credential[Username],
        password = credential[Password],

        // Login API
        loginResponse =
            Json.Document(
                Web.Contents(
                    "https://kpifire.com/api/login",
                    [
                        Headers = [#"Content-Type"="application/json"],
                        Content = Text.ToBinary(
                            "{""username"":""" & username & """,""password"":""" & password & """}"
                        )
                    ]
                )
            ),

        token = loginResponse[token],

        // Fetch Data using token
        response =
            Json.Document(
                Web.Contents(
                    "https://kpifire.com/api/projects",
                    [
                        Headers = [
                            Authorization = "Bearer " & token
                        ]
                    ]
                )
            ),

        table = Table.FromList(response, Splitter.SplitByNothing()),
        expanded = Table.ExpandRecordColumn(table,"Column1",{"id","name","status"})
    in
        expanded;


// ================================
// Authentication
// ================================

KPIFireDemoConnector = [
    TestConnection = (dataSourcePath) => { "KPIFireDemoConnector.Contents" },
    Authentication = [
        UsernamePassword = []
    ],
    Label = "KPIFire Connector"
];


// ================================
// Publish Info
// ================================

KPIFireDemoConnector.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = { "KPIFire", "Connect to KPIFire" },
    LearnMoreUrl = "https://kpifire.com",
    SourceImage = KPIFireDemoConnector.Icons,
    SourceTypeImage = KPIFireDemoConnector.Icons
];


KPIFireDemoConnector.Icons = [
    Icon16 = { Extension.Contents("KPIFireDemoConnector16.png"), Extension.Contents("KPIFireDemoConnector20.png") },
    Icon32 = { Extension.Contents("KPIFireDemoConnector32.png"), Extension.Contents("KPIFireDemoConnector40.png") }
];
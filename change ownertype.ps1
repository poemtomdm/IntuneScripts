install-module microsoft.graph
import-module microsoft.graph

connect-mggraph

$JSON = @"
{
    ownerType:"company"
}
"@

$ids="f60c9f62-f46a-4dd7-9236-0f34b03ffdfd",
"ad7372fc-194e-4ad5-a098-7fb5d497895c",
"515a3ac8-15cc-40c9-bf4f-10e1b8d2b84b",
"ef1085a8-169f-4823-ae63-c4d83f3c5237",
"cb37afd1-4c5a-4beb-8e7d-bbffc7f98772",
"711b6865-59b6-4c4c-9a87-b45aea0c2a80",
"d54fb1de-d885-4afb-8a75-7e75d1e699f2",
"c59063e3-3cc8-43f5-84be-4976ea536640",
"1cfcc1bb-057e-4618-a592-b16f49417a45",
"57b978cc-a96f-4716-a30d-e73d064652a9",
"2a41ca2d-2614-4543-ae18-fa31848f6ef9",
"b7e34cf2-bd55-4204-9802-423c66de74d9",
"04d59d76-2d06-4ab7-aae6-637c5a4e9f98",
"6822f3b2-ea43-463c-8663-48b07861b8ad",
"ea673727-afd7-4c91-af66-f90f9c72286d",
"f99d76c3-b3ed-4ce8-ad9d-64f3139be11f",
"24c4089a-f60a-40c1-a40d-0491fdf9bc58",
"3cafe17e-afdd-48c9-a860-e071049ed4cb",
"be2923b7-6b1e-4876-b7ab-372915fb27c0",
"ebd330a2-4a60-4094-8f1e-feb200417544",
"47ebffa0-a3d9-4406-8a77-ae39354d09bd",
"8ce6df7c-86bf-4bf9-a14b-72997c96cf1a",
"042aed3c-c32f-4dde-9656-03901777d1bb",
"345c946f-33d7-4564-a7d9-db7b07a12b29",
"6cdb73cd-8612-456f-8122-7aa04057018b",
"275b7bef-0b62-423a-af5a-233fd7a5cb04",
"643c1013-207b-4f22-ad85-db3c8151b3f8",
"8ae64e35-5323-4a3f-a4c4-331036936f64",
"84a6b728-6fdf-4cd9-996f-202904f2e247",
"d22cbc5b-2e17-47c9-8609-e54cad33d4d7",
"ddded1c3-78fc-4cdd-bda9-750a3d9f05c0",
"6e52d81e-8f8c-4558-8146-214ddd7f5009",
"b6887c6a-aafc-4fa6-bc88-1a0070660e49",
"d36733c9-102e-460f-b0f8-dc8c930c7683",
"fc5adef0-e948-4003-a4b8-8b143414fbbc",
"8b7e03b8-73c8-4fa4-b339-5cfba5d3d53f",
"9a2cbaf3-d377-45ee-a9f5-1a7d62fadf30",
"8370b5b5-3753-4dbf-bb3f-7ce7c9d2155c",
"c4b0bf0e-8063-433e-8cb7-93bae3b4b70a",
"5d427285-7a4b-49bc-8191-2554fef00351",
"8245fb02-fd22-42fb-b337-821c1009f619",
"2e9c7d72-b2d6-460e-993d-2478ff6a41f9",
"10201eab-e51a-46c1-a0f3-cd842d1f01f2",
"d80c4d58-c70f-491e-90a9-c86271209787",
"64f498be-ab0f-4430-b0af-d02eb269191a",
"c619f393-a20d-411d-968d-c02a605d398c",
"12e21e06-2b50-4e1a-b9f3-71eb30cf42ca",
"85d07eaa-29ed-40d6-b851-fcf50f2696a9",
"0b8ed8b6-a94f-4066-b005-a27bfd688e1e",
"5c6568a6-0a5a-4850-8e02-5f5816217e8d",
"f5c4aff4-a9fb-4f87-b980-276a5293fc08",
"a0a57e5d-182c-408f-af09-d08ce0cde2ac",
"da481cb7-73f1-4fa4-ac73-45cb335cc66c",
"bdaaaba1-a1ef-4bc1-8d15-366c92f846a2",
"8bdd320f-c946-4e33-9e35-e58338f0da34",
"092c1989-ebc2-4e1d-b15e-dbf27e9a27fe",
"e6af8fdd-7e14-4cd9-89b8-147d0878dfc7",
"54c29223-7d59-40bd-a0a1-f7137d10d463",
"ec5c58c4-e67f-4e6f-8dd7-c2b31b25967b",
"c59b7723-2a52-480f-9c61-72bc4bb107e0",
"308d1c0c-29f7-425c-96bd-a42cf852a421",
"4d6df612-abdf-4f19-8f5a-1eaf06156039"

foreach ($id in $ids) {

$uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices('$id')"
Invoke-MgGraphRequest -Uri $uri -Body $json -method Patch -ContentType "application/json"
}
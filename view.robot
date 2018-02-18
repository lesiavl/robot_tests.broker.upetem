*** Settings ***
Library  Selenium2Library
Library  String
Library  DateTime
Library  upetem_service.py
Resource  upetem.robot

*** Keywords ***

Отримати інформацію про title
  ${return_value}=   Get Text  xpath=//*[@id="mForm:name"]
  [return]  ${return_value}

Отримати інформацію про description
  ${return_value}=   Get Text  xpath=//*[@id="mForm:desc"]
  [return]  ${return_value}

Отримати інформацію про value.amount
  ${value}=    Get Text    xpath=//*[@id='mForm:budgetL']
  ${return_value}=   Convert To Number   ${value}
  [return]  ${return_value}

Отримати інформацію про minimalStep.amount
  ${type_tender}=    Get Text            xpath=//*[@id='mForm:procurementMethodName']
  ${value_below}=  Get Value    xpath=//*[@id='mForm:step']
  ${value_open}=  Get Value           xpath=//*[@id='mForm:lotStep0']
  ${return_value}=    Set Variable If    '${type_tender}' == 'Допорогові закупівлі'    ${value_below}    ${value_open}
  ${return_value}=  Convert To Number    ${return_value}
  [return]  ${return_value}

Отримати інформацію про procurementMethodType
  ${return_value}=    Get Text    xpath=//*[@id='mForm:procurementMethodName']
  ${return_value}=    convert_type_tender    ${return_value}
  [return]  ${return_value}

Отримати інформацію про value.currency
  ${return_value}=  Get Text  id=mForm:currency_label
  ${return_value}=  Convert To String  UAH
  [return]  ${return_value}

Отримати інформацію про value.valueAddedTaxIncluded
  ${return_value}=  Convert To Boolean  True
  [return]  ${return_value}

Отримати інформацію про enquiryPeriod.startDate
  ${return_value}=  Get Text           xpath=//*[@id="mForm:da"]
  ${return_value}=  upetem_service.parse_date  ${return_value}
  [return]  ${return_value}

Отримати інформацію про enquiryPeriod.endDate
  ${type_tender}=    Get Text           xpath=//*[@id='mForm:procurementMethodName']
  ${value_open}=    Get Text    xpath=//label[text()='Дата завершення періоду уточнень']//ancestor::tr/td[4]
  ${value_below}=    Get Value    xpath=//*[@id="mForm:dEA_input"]
  ${return_value}=    Set Variable If    '${type_tender}' != 'Допорогові закупівлі'    ${value_open}
  ...                                '${type_tender}' == 'Допорогові закупівлі'    ${value_below}
  ${return_value}=  upetem_service.parse_date  ${return_value}
  [return]  ${return_value}

Отримати інформацію про complaintPeriod.endDate
  ${return_value}=    Get Value    xpath=//*[@id='mForm:dEPr_input']
  ${return_value}=    upetem_service.parse_complaintPeriod_date    ${return_value}
  [return]  ${return_value}

Отримати інформацію про tenderPeriod.startDate
  ${type_tender}=    Get Text          xpath=//*[@id='mForm:procurementMethodName']
  ${value_open}=    Get Text           xpath=//*[@id="mForm:da"]
  ${value_below}=  Get Value           xpath=//*[@id="mForm:dSPr_input"]
  ${return_value}=    Set Variable If    '${type_tender}' != 'Допорогові закупівлі'    ${value_open}
  ...                                '${type_tender}' == 'Допорогові закупівлі'    ${value_below}
  ${return_value}=  upetem_service.parse_date  ${return_value}
  [return]  ${return_value}

Отримати інформацію про tenderPeriod.endDate
  ${return_value}=  Get Value           xpath=//*[@id="mForm:dEPr_input"]
  ${return_value}=  upetem_service.parse_date  ${return_value}
  [return]  ${return_value}

Отримати інформацію про procuringEntity.name
  ${return_value}=  Get Text           xpath=//*[@id="mForm:orgName"]
  [return]  ${return_value}

Отримати інформацію про tenderID
  ${return_value}=  Get Text           id=mForm:nBid
  ${return_value}=  Get Substring  ${return_value}  19
  ${return_value}=  Convert To String  ${return_value}
  [return]  ${return_value}

Отримати інформацію про status
  Run Keyword If    '${TEST_NAME}' == 'Неможливість завантажити документ першим учасником після закінчення прийому пропозицій'  Wait Until Keyword Succeeds  480 s  20 s  subkeywords.Wait For EndEnquire
  Run Keyword If    '${TEST_NAME}' == 'Неможливість задати запитання на тендер після закінчення періоду уточнень'    Sleep  30
  Run Keyword If    '${TEST_NAME}' == 'Неможливість задати запитання на тендер після закінчення періоду уточнень'    Reload Page
  Run Keyword If    '${TEST_NAME}' == 'Можливість вичитати посилання на аукціон для глядача'    Reload Page
  Run Keyword If    '${TEST_NAME}' == 'Можливість подати пропозицію першим учасником'      Wait Until Keyword Succeeds    480 s    20 s    subkeywords.Wait For TenderPeriod
  ${return_value}=    Get Text    xpath=//*[@id='mForm:status']
  ${return_value}=    upetem_service.convert_status    ${return_value}
  [return]  ${return_value}


Отримати інформацію про items[0].description
  ${return_value}=  Get Text           xpath=//*[@id="mForm:bidItem_0:subject"]
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryDate.startDate
  ${return_value}=  Get Value  xpath=//*[@id="mForm:lotItems0:lotItem_0:item0"]//tr[9]/td[4]/input
  ${return_value}=  upetem_service.parse_item_date  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryDate.endDate
  ${return_value}  Get Value  xpath=//*[@id="mForm:lotItems0:lotItem_0:item0"]/tbody/tr[10]/td[4]/input
  ${return_value}=  upetem_service.parse_item_date  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[1].deliveryDate.endDate
  ${return_value}  Get Value  xpath=//*[@id="mForm:lotItems0:lotItem_1:item1"]/tbody/tr[10]/td[4]/input
  ${return_value}=  upetem_service.parse_item_date  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryLocation.latitude
  ${return_value}=  Get Value           xpath=//*[@id="mForm:lotItems0:lotItem_0:delLoc1"]
  Run Keyword And Return  Convert To Number  ${return_value}

Отримати інформацію про items[0].deliveryLocation.longitude
  ${return_value}=  Get Value           xpath=//*[@id="mForm:lotItems0:lotItem_0:delLoc2"]
  Run Keyword And Return  Convert To Number  ${return_value}

Отримати інформацію про items[0].deliveryAddress.countryName
  ${return_value}=  Get Text           xpath=//*[@id="mForm:bidItem_0:nState"]
  ${return_value}=  capitalize_first_letter  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.postalCode
  ${return_value}=  Get Value           xpath=//*[@id='mForm:bidItem_0:zc']
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.region
  ${return_value}=  Get Value           xpath=//*[@id='mForm:bidItem_0:cRegName']
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.locality
  ${return_value}=  Get Value           xpath=//*[@id='mForm:bidItem_0:cTer_input']
  ${return_value}=    capitalize_first_letter    ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.streetAddress
  ${return_value}=  Get Value           xpath=//*[@id="mForm:bidItem_0:delAdr"]
  [return]  ${return_value}

Отримати інформацію про items[0].classification.scheme
  ${return_value}=  Get Text           xpath=(//*[@id="mForm:bidItem_0:item0"]/tbody/tr[3]/td/label)[1]
  ${return_value}=  Get Substring  ${return_value}  36  39
  ${return_value}=  Convert To String  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].classification.id
  ${return_value}=  Get Value           xpath=//*[@id="mForm:bidItem_0:cCpv_input"]
  [return]  ${return_value}

Отримати інформацію про items[0].classification.description
  ${return_value}=  Get Text           xpath=//*[@id="mForm:bidItem_0:nCpv"]
  [return]  ${return_value}

Отримати інформацію про items[0].additionalClassifications[0].scheme
  ${return_value}=  Get Text   xpath=(//*[@id="mForm:lotItems0:lotItem_0:item0"]/tbody/tr[2]//label)[2]
  [return]  ${return_value}

Отримати інформацію про items[0].additionalClassifications[0].id
  ${return_value}=  Get Value           xpath=//*[@id="mForm:bidItem_0:cDkpp_input"]
  [return]  ${return_value}

Отримати інформацію про items[0].additionalClassifications[0].description
  ${return_value}=  Get Text           xpath=//*[@id="mForm:bidItem_0:nDkpp"]
  ${return_value}=  Strip String  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].unit.name
  ${return_value}=  Get Value                     xpath=//*[@id="mForm:bidItem_0:unit_input"]
  ${return_value}=  Get Substring                 ${return_value}  4
  ${return_value}=  Convert To String             ${return_value.replace(' ', '')}
  ${return_value}=  upetem_service.adapt_unit_name    ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].unit.code
  ${return_value}=  Get Value           xpath=//*[@id="mForm:bidItem_0:unit_input"]
  ${return_value}=  Get Substring  ${return_value}  0  3
  ${return_value}=  Convert To String  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].quantity
  ${return_value}=  Get Value           xpath=//*[@id="mForm:bidItem_0:amount-read-only"]
  ${return_value}=  Convert To Number  ${return_value}
  [return]  ${return_value}

Отримати інформацію про tender_document.title
  ${return_value}=  Get Text           xpath=(//*[@id='mForm:pnlFiles']//a[1])[2]
  [return]  ${return_value}

Отримати інформацію про questions[0].title
  Sleep  5
  Click Element  xpath=//*[text()="Обговорення"]
  Sleep  5
  ${return_value}=  Get Text  xpath=//*[@id="mForm:data_data"]/tr[1]/td[1]/span[1]
  [return]  ${return_value}

Отримати інформацію про questions[0].description
  Sleep  5
  Click Element  xpath=//*[text()="Обговорення"]
  Sleep  5
  ${return_value}=  Get Text  xpath=//*[@id="mForm:data_data"]/tr[1]/td[1]/span[2]
  [return]  ${return_value}

Отримати інформацію про questions[0].date
  Sleep  5
  Click Element  xpath=//*[text()="Обговорення"]
  Sleep  5
  ${return_value}=  Get Text  xpath=//*[@id="mForm:data_data"]/tr/td[4]
  [return]  ${return_value}

Отримати інформацію про questions[0].answer
  Sleep  5
  Click Element  xpath=//*[text()="Обговорення"]
  Sleep  5
  ${return_value}=  Get Text  xpath=//*[@id="mForm:data_data"]/tr[2]/td[1]/span[2]
  [return]  ${return_value}

Отримати інформацію про awards[0].complaintPeriod.endDate
  Run Keyword If  '${TEST NAME}'=='Відображення закінчення періоду подачі скарг на пропозицію'  Подивитись на учасників
  ${contract_caption}  Set Variable If  '${MODE}'=='belowThreshold'  Оформити договір  Договір
  ${contract_caption}  Set Variable If  '${MODE}'=='belowThreshold' and '${ROLE}'=='viewer'  Перегляд оцінки  ${contract_caption}
  ${contract_button_is_visible}  Run Keyword And Return Status  Element Should Be Visible  jquery=span:contains('${contract_caption}')
  Run Keyword If  ${contract_button_is_visible}  Click Element  jquery=span:contains('${contract_caption}')
  Sleep  5
  ${period}  Run Keyword And Return Status  Page Should Contain  Період оскаржень
  ${period_selector}  Set Variable If  ${period}  (//div[@id='mForm:data']//td[2])[1]  //*[@id='mForm:pTop']
  ${period_selector}  Set Variable If  '${MODE}'=='belowThreshold'  (//div[@id='mForm:data']/div)[1]  ${period_selector}
  ${period_index}  Set Variable If  ${period}  19  73
  ${period_index}  Set Variable If  '${MODE}'=='belowThreshold'  37  ${period_index}
  ${complaintPeriod}  Get Text  xpath=${period_selector}
  ${return_value}  upetem_service.parse_complaintPeriod_endDate  ${complaintPeriod[${period_index}:]}
  [return]  ${return_value}

Подивитись на учасників
  Run Keyword If  '${MODE}'=='belowThreshold'  Execute Javascript  document.getElementById("mForm:lotDesc0").scrollIntoView(false)
  Run Keyword If  '${MODE}'=='belowThreshold'  Click Element  jquery=span:contains('Результати аукціону')
  ${of_what}  Set Variable If  '${MODE}'=='belowThreshold'  аукціону  закупівлі
  Click Element  jquery=span:contains('Учасники ${of_what}')
  Run Keyword If  '${MODE}'!='belowThreshold'  Wait Until Element Is Visible  id=mForm:partList_list
  Run Keyword If  '${MODE}'!='belowThreshold'  Click Element  jquery=span:contains('Переглянути')
  Run Keyword If  '${MODE}'!='belowThreshold'  Wait Until Element Is Visible  id=mForm:tabs:award_status_label
  Run Keyword If  '${MODE}'=='belowThreshold'  Sleep  5

Отримати інформацію про causeDescription
  ${return_value}  Get Text  id=mForm:cause_description
  [return]  ${return_value}

Отримати інформацію про cause
  ${cause_text}  Get Text  xpath=//td[@id='mForm:cardCause']/label
  ${return_value}  upetem_service.convert_cause_type  ${cause_text[11]}
  [return]  ${return_value}

Отримати інформацію про procuringEntity.contactPoint.name
  ${return_value}  Get Value  id=mForm:rName
  [return]  ${return_value}

Отримати інформацію про procuringEntity.contactPoint.telephone
  ${return_value}  Get Value  id=mForm:rPhone
  [return]  ${return_value}

Отримати інформацію про procuringEntity.identifier.legalName
  ${return_value}  Get Text  id=mForm:orgFName
  [return]  ${return_value}

Отримати інформацію про documents[0].title
  ${return_value}  Get Text  xpath=//div[@id='mForm:pnlFiles']//a
  [return]  ${return_value}

Отримати інформацію про awards[0].documents[0].title
  Подивитись на учасників
  ${title}  Get Text  xpath=//div[@id='mForm:tabs:pnlFilesT']//a
  [return]  ${title}

Отримати інформацію про awards[0].status
  Подивитись на учасників
  ${status}  Get Text  id=mForm:tabs:award_status_label
  ${return_value}  Set Variable If  '${status}'=='Закупівлю виграв учасник'  active  other status
  [return]  ${return_value}

Отримати інформацію про awards[0].suppliers[0].contactPoint.telephone
  Подивитись на учасників
  ${return_value}  Get Value  id=mForm:tabs:rPhone
  [return]  ${return_value}

Отримати інформацію про awards[0].suppliers[0].contactPoint.name
  Подивитись на учасників
  ${return_value}  Get Value  id=mForm:tabs:rName
  [return]  ${return_value}

Отримати інформацію про awards[0].suppliers[0].contactPoint.email
  Подивитись на учасників
  ${return_value}  Get Value  id=mForm:tabs:rMail
  [return]  ${return_value}

Отримати інформацію про contracts[0].status
  ${contract_button_is_not_visible}  Run Keyword And Return Status  Page Should Not Contain Element  jquery=span:contains('Договір')
  Run Keyword If  ${contract_button_is_not_visible}  Подивитись на учасників
  Click Element  jquery=span:contains('Договір')
  Wait Until Element Is Visible  id=mForm:pAcc:contract_status_label
  ${pending}  Set Variable  цей договір запропоновано, але він ще не діє. Можливо очікується його підписання
  ${active}  Set Variable  цей договір підписаний всіма учасниками, і зараз діє на законних підставах
  ${wait_for}  Set Variable If  '${TEST NAME}'=='Відображення статусу непідписаної угоди з постачальником переговорної процедури'  ${pending}  ${active}
  :FOR    ${INDEX}    IN RANGE    1    11
  \  ${status}  Get Text  id=mForm:pAcc:contract_status_label
  \  Exit For Loop If  '${status}' == '${wait_for}'
  \  Sleep  15
  \  Reload Page
  ${return_value}  Set Variable If
  ...  '${status}'=='${active}'  active
  ...  '${status}'=='${pending}'  pending
  [return]  ${return_value}

Отримати інформацію про lots[0].title
  ${return_value}  Get Text  id=mForm:lotTitle0
  [return]  ${return_value}

Отримати інформацію про lots[0].value.amount
  ${value}  Get Value  id=mForm:lotBudg0
  ${return_value}  Convert To Number   ${value}
  [return]  ${return_value}

Отримати інформацію про lots[0].description
  ${return_value}  Get Text  id=mForm:lotDesc0
  [return]  ${return_value}

Отримати інформацію про lots[0].minimalStep.amount
  ${lotStep0}  Get Value  id=mForm:lotStep0
  ${return_value}  Convert To Number    ${lotStep0}
  [return]  ${return_value}

Отримати інформацію про features[3].title
  ${return_value}  Get Value  xpath=//div[@id='mForm:lotItems0:meatDataLot0']/table[2]/tbody/tr[1]/td[2]
  [return]  ${return_value}

Отримати інформацію про qualifications[0].status
  Click Element  jquery=span:contains('Кваліфікація учасників')
  Wait Until Page Contains Element  id=mForm:qualificationData
  ${return_value}  Get Text  xpath=(//table)[1]//tr[2]/td[2]/span
  [return]  ${return_value}

Отримати інформацію про qualifications[1].status
  ${return_value}  Get Text  xpath=(//table)[6]//tr[2]/td[2]/span
  [return]  ${return_value}
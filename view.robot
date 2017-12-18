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
#  ${value}=    Run Keyword If    '${mode}' == 'belowThreshold'    Get Text    xpath=//*[@id='mForm:budgetL']
#  ...          ELSE IF           '${mode}' != 'belowThreshold'    Get Text     xpath=//*[@id='mForm:budget']
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
  #${return_value}=  Get Value           xpath=//*[@id="mForm:dEA_input"]
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
  #Run Keyword If    '${TEST_NAME}' == 'Неможливість задати запитання на тендер після закінчення періоду уточнень'  Wait Until Keyword Succeeds  480 s  20 s  subkeywords.Wait For EndEnquire
  Run Keyword If    '${TEST_NAME}' == 'Можливість подати пропозицію першим учасником'      Wait Until Keyword Succeeds    480 s    20 s    subkeywords.Wait For TenderPeriod
  ${return_value}=    Get Text    xpath=//*[@id='mForm:status']
  ${return_value}=    upetem_service.convert_status    ${return_value}
  [return]  ${return_value}


Отримати інформацію про items[0].description
  ${return_value}=  Get Text           xpath=//*[@id="mForm:bidItem_0:subject"]
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryDate.startDate
  ${return_value}=  Get Value           xpath=//*[@id="mForm:bidItem_0:item0"]/tbody/tr[4]/td[4]/input
  ${return_value}=  upetem_service.parse_item_date  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryDate.endDate
  ${return_value}=  Get Value           xpath=//*[@id="mForm:bidItem_0:item0"]/tbody/tr[5]/td[4]/input
  ${return_value}=  upetem_service.parse_item_date  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryLocation.latitude
  ${return_value}=  Get Value           xpath=//*[@id="mForm:bidItem_0:delLoc1"]
  Run Keyword And Return  Convert To Number  ${return_value}

Отримати інформацію про items[0].deliveryLocation.longitude
  ${return_value}=  Get Value           xpath=//*[@id="mForm:bidItem_0:delLoc2"]
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
  ${return_value}=  Get Text           xpath=(//*[@id="mForm:bidItem_0:item0"]/tbody/tr[3]/td[3]/label)[2]
  ${return_value}=  Get Substring  ${return_value}  36  40
  ${return_value}=  Convert To String  ${return_value}
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
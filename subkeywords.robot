*** Settings ***

Library  Selenium2Library
Library  String
Library  DateTime
Library  Collections
Library  upetem_service.py
Library  get_xpath.py


*** Keywords ***

Змінити дату
  [Arguments]  ${fieldvalue}
  Clear Element Text    xpath=//*[@id='mForm:dEPr_input']
  ${endDate}=           upetem_service.convert_date_to_string    ${fieldvalue}
  Input Text            xpath=//*[@id='mForm:dEPr_input']    ${endDate}

Змінити опис
  [Arguments]  ${fieldvalue}
  Clear Element Text    xpath=//*[@id='mForm:desc']
  Input Text            xpath=//*[@id='mForm:desc']    ${fieldvalue}
  Sleep  120

Отримати дані з поля item
  [Arguments]  ${field}  ${item_id}
  ${field_xpath}=    get_xpath.get_item_xpath    ${field}    ${item_id}
  ${type_field}=    upetem_service.get_type_field    ${field}
  ${value} =  Run Keyword If    '${type_field}' == 'value'    Get Value    ${field_xpath}
    ...     ELSE IF             '${type_field}' == 'text'    Get Text    ${field_xpath}
  [return]  ${value}

Адаптувати дані з поля item
  [Arguments]  ${field}  ${value}
  ${value}=  Run Keyword If    '${field}' == 'unit.name'    upetem_service.get_unit    ${field}    ${value}
    ...      ELSE IF           '${field}' == 'unit.code'    upetem_service.get_unit    ${field}    ${value}
    ...      ELSE IF           '${field}' == 'quantity'     Convert To Number    ${value}
    ...      ELSE IF           '${field}' == 'deliveryLocation.latitude'    Convert To Number    ${value}
    ...      ELSE IF           '${field}' == 'deliveryLocation.longitude'    Convert To Number    ${value}
    ...      ELSE IF           '${field}' == 'deliveryDate.startDate'    upetem_service.parse_item_date    ${value}
    ...      ELSE IF           '${field}' == 'deliveryDate.endDate'    upetem_service.parse_item_date    ${value}
    ...      ELSE IF           '${field}' == 'classification.scheme'    Get Scheme    ${value}
    ...      ELSE               Set Variable    ${value}
  [return]  ${value}

Отримати дані з поля lot
  [Arguments]  ${field}  ${lot_id}  ${mode}
  ${field_xpath}=    get_xpath.get_lot_xpath    ${field}    ${lot_id}    ${mode}
  ${type_field}=    upetem_service.get_type_field    ${field}
  ${value}=  Run Keyword If    '${type_field}' == 'value'    Get Value    ${field_xpath}
  ...        ELSE IF           '${type_field}' == 'text'    Get Text    ${field_xpath}
  [return]  ${value}

Адаптувати дані з поля lot
  [Arguments]  ${field}  ${value}
  ${value}=  Run Keyword If    '${field}' == 'value.amount'    Convert To Number    ${value}
  ...        ELSE IF           '${field}' == 'minimalStep.amount'    Convert To Number    ${value}
  ...        ELSE IF           '${field}' == 'value.currency'    upetem_service.convert_data_lot    ${value}
  ...        ELSE IF           '${field}' == 'minimalStep.currency'    upetem_service.convert_data_lot    ${value}
  ...        ELSE IF           '${field}' == 'value.valueAddedTaxIncluded'    Convert To Boolean    True
  ...        ELSE IF           '${field}' == 'minimalStep.valueAddedTaxIncluded'    Convert To Boolean    True
  ...        ELSE              Set Variable    ${value}
  [return]  ${value}

Отримати дані з поля feature
  [Arguments]  ${field_name}  ${feature_id}
  ${field_xpath}=    upetem_service.get_feature_xpath    ${field_name}  ${feature_id}
  ${type_field}=    upetem_service.get_type_field    ${field_name}
  ${value}=  Run Keyword If    '${type_field}' == 'value'    Get Value    ${field_xpath}
  ...        ELSE IF           '${type_field}' == 'text'    Get Text    ${field_xpath}
  [return]  ${value}

Get Scheme
  [Arguments]  ${value}
  ${value}=    Replace String    ${value[4:10]}    ${space}    ${empty}
  [return]  ${value}

Wait For Question
  [Arguments]  ${field_xpath}
  Reload page
  Sleep  3
  Page Should Contain Element    xpath=${field_xpath}

Wait For TenderPeriod
  Reload Page
  Sleep  3
  Page Should Contain Element    xpath=//*[text()='Очікування пропозицій']

Wait For AuctionPeriod
  Reload Page
  Sleep  3
  Page Should Contain Element    xpath=//*[text()='Період аукціону']

Wait For NewLot
  Reload Page
  Sleep  3
  Page Should Contain Element    xpath=//*[@id='lotTabButton_2']

Wait For NewItem
  [Arguments]  ${item_id}
  Reload Page
  Sleep  3
  Execute JavaScript                  window.scrollTo(0, 1000)
  Sleep  2
  Click Element    xpath=//*[@id='lotTabButton_2']
  Sleep  2
  Page Should Contain Element    xpath=//*[contains(text(), '${item_id}')]

Wait For NewFeature
  [Arguments]  ${feature_id}
  Reload Page
  Sleep  3
  Page Should Contain Element    xpath=//*[contains(@value, '${feature_id}')]

Wait For Document
  [Arguments]  ${field_xpath}
  Reload Page
  Sleep  3
  Page Should Contain Element    xpath=${field_xpath}

Wait For ClaimTender
  Reload Page
  Sleep  3
  Page Should Contain Element    xpath=(//*[@id='mForm:data_data']/tr/td[1]/a)[1]

Wait For ClaimLot
  Reload Page
  Sleep  3
  Page Should Contain Element    xpath=(//*[@id='mForm:data_data']/tr/td[1]/a)[2]

Wait For Answered
  Reload Page
  Sleep  5
  Page Should Contain Element    xpath=//*[@id='mForm:data:resolutionType_label']

Wait For Resolved
  Reload Page
  Sleep  5
  Element Should Contain  xpath=(//tbody/tr[1]/td[2])[1]  Вирішена

Wait For Ignored
  Reload Page
  Sleep  5
  Element Should Contain  xpath=(//tbody/tr[1]/td[2])[1]  Проігнорована

Wait For Invalid
  Reload Page
  Sleep  5
  Element Should Contain  xpath=(//tbody/tr[1]/td[2])[1]  Недійсна

Wait For Declined
  Reload Page
  Sleep  5
  Element Should Contain  xpath=(//tbody/tr[1]/td[2])[1]  Відхилена

Wait For Satisfied
  Reload Page
  Sleep  5
  Page Should Contain Element    xpath=//*[@id='mForm:data:satisfied_label']

Wait For Cancelled
  Reload Page
  Sleep  5
  Page Should Contain Element    xpath=//*[text()='Відхилено']

Wait For EndEnquire
  Reload Page
  Sleep  3
  Page Should Not Contain Element    xpath=//*[text()='Очікування пропозицій']

Wait For Status
  Reload Page
  Sleep  3
  Page Should Contain Element    xpath=//*[text()='Недійсна пропозиція']


Switch new lot
  [Arguments]  ${username}  ${tender_uaid}
  upetem.Пошук тендера по ідентифікатору    ${username}  ${tender_uaid}
  Wait Until Keyword Succeeds    180 s    10 s    subkeywords.Wait For NewLot
  Execute JavaScript                  window.scrollTo(0, 1000)
  Sleep  2
  Click Element    xpath=//*[@id='lotTabButton_2']
  Sleep  2

Подати цінову пропозицію для open
  [Arguments]  ${bid}  ${lots_ids}  ${features_ids}

  ${number_lots}=    Get Length    ${bid.data.lotValues}
  ${meat}=  Evaluate  ${tender_meat} + ${lot_meat} + ${item_meat}
  ${lot_ids}=  Run Keyword If  ${lots_ids}  Set Variable  ${lots_ids}
  ...    ELSE  Create List
  Set Suite Variable    @{ID}    ${lot_ids}

  :FOR  ${index}  ${lot_id}  IN ENUMERATE  @{lot_ids}
  \  Execute JavaScript                window.scrollTo(0, 550)
  \  Sleep  3
  \  Click Element    xpath=(//span[contains(text(), '${lot_id}')]//ancestor::div[2]/div[2]//button/span)[1]
  \  Sleep  10
  \  ${amount}=    upetem_service.convert_float_to_string    ${bid.data.lotValues[${index}].value.amount}
  \  Sleep  5
  \  Input Text    xpath=//span[contains(text(), '${lot_id}')]//ancestor::div[2]/div[2]/table/tbody/tr[7]/td[2]//input    ${amount}

  Run Keyword If    ${meat} > 0    subkeywords.Обрати неціновий показник    ${bid}    ${features_ids}

  Execute JavaScript   window.scrollTo(0, 0)
  Click Element    xpath=(//*[@id='mForm:data:selfQualified']//span[1])[1]
  Click Element    xpath=//*[@id='mForm:data:selfEligible']/div[2]/span

Подати цінову пропозицію для below
  [Arguments]  ${bid}
  ${input_selector}=  Set Variable If  ${NUMBER_OF_LOTS}==0  //*[@id='mForm:data:amount']  //*[@id='mForm:data:lotAmount0']
  Wait Until Element Is Visible    xpath=${input_selector}    30
  ${float_amount}=  Set Variable If  ${NUMBER_OF_LOTS}==0  ${bid.data.value.amount}  ${bid.data.lotValues[0].value.amount}
  ${amount}=    upetem_service.convert_float_to_string    ${float_amount}
  Run Keyword If  ${NUMBER_OF_LOTS}==1  Click Element  xpath=//*[@id='mForm:data:lotData0_content']/div/button/span  # Подати пропозицію по лоту
  Sleep  3
  Input Text    xpath=${input_selector}    ${amount}

Обрати неціновий показник
  [Arguments]  ${bid}  ${features_ids}
  ${numbers_feature}=  Get Length  ${bid.data.parameters}
  ${features_ids}=  Run Keyword If  ${features_ids}  Set Variable  ${features_ids}
  ...    ELSE  Create List
  :FOR  ${index}  ${feature_id}  IN ENUMERATE  @{features_ids}
  \  ${feature_of}=    Get Text    xpath=//*[contains(text(), '${feature_id}')]//ancestor::tbody/tr[2]/td[2]/label
  \  ${pos}=    upetem_service.get_pos    ${feature_of}
  \  ${value}=    upetem_service.get_value_feature    ${bid.data.parameters[${index}]['value']}
  \  ${dropdown_id}=	 Get Element Attribute	xpath=//*[contains(text(), '${feature_id}')]//ancestor::tbody/tr[4]/td[2]/div@id
  \  Execute Javascript  document.getElementById("${dropdown_id}").scrollIntoView(false)
  \  Click Element    id=${dropdown_id}
  \  Sleep  3
  \  Click Element    xpath=//ul[@id="${dropdown_id}_items"]/li[contains(text(), "${value}")]


Отримати дані з bid below
  ${element_selector}=  Set Variable If  ${NUMBER_OF_LOTS}==0  //*[@id='mForm:data:amount']  //*[@id='mForm:data:lotAmount0']
  ${value}=    Get value    xpath=${element_selector}
  ${value}=    Convert To Number    ${value}
  [return]  ${value}


Отримати дані з bid open
  [Arguments]  ${field}
  ${xpath}=    get_xpath.get_bid_xpath    ${field}    @{ID}
  Sleep  10
  Reload Page
  ${value}=  Run Keyword If    '${field}' != 'status'    Get Value    xpath=${xpath}
  ...        ELSE IF           '${field}' == 'status'    Get Text    xpath=${xpath}
  ${return_value}=  Run Keyword If    '${field}' != 'status'    Convert To Number    ${value}
  ...        ELSE IF           '${field}' == 'status'    upetem_service.convert_bid_status    ${value}
  [return]  ${return_value}


Змінити цінову пропозицію below
  [Arguments]  ${fieldvalue}
  ${value}=    Convert To String    ${fieldvalue}
  ${element_selector}=  Set Variable If  ${NUMBER_OF_LOTS}==0  //*[@id='mForm:data:amount']  //*[@id='mForm:data:lotAmount0']
  Clear Element Text    xpath=${element_selector}
  Sleep  1
  Input Text    xpath=${element_selector}    ${value}
  Sleep  2
  Click Element    xpath=//span[text()='Зберегти']
  Sleep  15


Змінити цінову пропозицію open
  [Arguments]  ${fieldname}  ${fieldvalue}
  Run Keyword If    '${fieldname}' == 'status'    subkeywords.Підтвердити пропозицію
  Run Keyword If    '${fieldname}' != 'status'    subkeywords.Змінити ставку    ${fieldname}    ${fieldvalue}


Змінити ставку
  [Arguments]  ${fieldname}  ${fieldvalue}
  ${xpath}=    get_xpath.get_bid_xpath    ${fieldname}    @{ID}
  ${value}=    Convert To String    ${fieldvalue}
  Clear Element Text    xpath=${xpath}
  Sleep  1
  Input Text    xpath=${xpath}    ${value}
  Sleep  2
  Click Element    xpath=//span[text()='Зберегти']
  Sleep  15


Підтвердити пропозицію
  Wait Until Keyword Succeeds  420 s  15 s  subkeywords.Wait For Status
  Click Element    xpath=//*[text()='Підтвердити пропозицію']
  Sleep  30

Заповнити картку організації
    [Arguments]  ${tender_data}
    ${data}  Set Variable  ${tender_data.data.procuringEntity}
    Wait Until Element Is Visible  css=div.cabinet-user-name
    Click Element  css=div.cabinet-user-name
    Wait Until Page Contains Element  css=span.nav-icon
    Click Element  css=span.nav-icon
    Sleep  1
    Click Link  Мої організації
    Wait Until Page Contains Element  css=tr.ui-widget-content.ui-datatable-even td a
    Click Element  css=tr.ui-widget-content.ui-datatable-even td a
    Wait Until Page Contains Element  id=mForm:grid
    Input Text  id=mForm:tin  ${data.identifier.id}
    Input Text  id=mForm:sn   ${data.name}
    Input Text  id=mForm:fn   ${data.identifier.legalName}
    Click Element  id=mForm:cReg_label
    ${region}  upetem_service.get_delivery_region  ${data.address.region}
    Click Element  jquery=li:contains('${region}')
    Input Text  id=mForm:cTer_input  ${data.address.locality}
    Wait Until Keyword Succeeds  3x  1  Wait Until Element Is Visible  id=mForm:cTer_panel
    Click Element  xpath=(//div[@id='mForm:cTer_panel']//tr)[1]
    Input Text  id=mForm:zc  ${data.address.postalCode}
    Input Text  id=mForm:adr  ${data.address.streetAddress}
    Click Element  jquery=span.ui-c:contains('Зберегти')
    ${already_exists}  Run Keyword And Return Status  Element Should Be Visible  id=primefacesmessagedlg
    Run Keyword If  ${already_exists}  upetem_service.increment_identifier  ${tender_data}
    Run Keyword If  ${already_exists}  Заповнити картку організації  ${tender_data}

Оголосити тендер
    Execute JavaScript  window.scrollTo(0,0)
    Wait Until Keyword Succeeds  3x  1  Wait Until Element Is Visible  xpath=//span[text()="Оголосити"]
    Click Element  xpath=//span[text()="Оголосити"]
    Click Element  xpath=//div[contains(@class, "ui-confirm-dialog") and @aria-hidden="false"]//span[text()="Оголосити"]
    Wait Until Keyword Succeeds  3x  1  Wait Until Element Is Visible       xpath=//span[contains(@class, "ui-button-text ui-c") and text()="Так"]
    Click Element  xpath=//span[contains(@class, "ui-button-text ui-c") and text()="Так"]

Додати мову закупівлі
  [Arguments]  ${description_en}  ${title_en}  ${name_en}  ${lots}  ${items}  ${features}
  Wait Until Element Is Visible  jquery=span:contains('Додати мову')
  Click Element  jquery=span:contains('Додати мову')
  Sleep  5
  Click Element  jquery=span:contains('English')
  Sleep  5
  Input Text  xpath=//tbody/tr[1]/td[3]/textarea   ${description_en}
  Input Text  xpath=//tbody/tr[3]/td[3]/textarea   ${title_en}
  Input Text  xpath=//tbody/tr[5]/td[3]/input      ${name_en}
  Input Text  xpath=//tbody/tr[7]/td[3]/input      ${lots[0].title_en}
  Input Text  xpath=//tbody/tr[9]/td[3]/input      opys lotu nomer odin
  Input Text  xpath=//tbody/tr[11]/td[3]/textarea  ${items[0].description_en}
  # features 0
  Input Text  xpath=//tbody/tr[15]/td[3]/input  ${features[0].title_en}
  Input Text  xpath=//tbody/tr[19]/td[3]/input  ${features[0].enum[0].title}
  Input Text  xpath=//tbody/tr[23]/td[3]/input  ${features[0].enum[1].title}
  Input Text  xpath=//tbody/tr[27]/td[3]/input  ${features[0].enum[2].title}
  # features 2
  Input Text  xpath=//tbody/tr[31]/td[3]/input  ${features[2].title_en}
  Input Text  xpath=//tbody/tr[35]/td[3]/input  ${features[2].enum[0].title}
  Input Text  xpath=//tbody/tr[39]/td[3]/input  ${features[2].enum[1].title}
  Input Text  xpath=//tbody/tr[43]/td[3]/input  ${features[2].enum[2].title}
  # features 1
  Input Text  xpath=//tbody/tr[47]/td[3]/input  ${features[1].title_en}
  Input Text  xpath=//tbody/tr[51]/td[3]/input  ${features[1].enum[0].title}
  Input Text  xpath=//tbody/tr[55]/td[3]/input  ${features[1].enum[1].title}
  Input Text  xpath=//tbody/tr[59]/td[3]/input  ${features[1].enum[2].title}

  Click Element  jquery=span:contains('Зберегти')
  Sleep  5

Ввести МНН код для всіх предметів
  [Arguments]  ${items}
  :FOR  ${index}  IN RANGE  ${NUMBER_OF_ITEMS}
  \  ${mnn_id}  Set Variable  ${items[${index}].additionalClassifications[0].id}
  \  Input Text  id=mForm:lotItems0:lotItem_${index}:mozInn_input  ${mnn_id}
  \  Wait Until Element Is Visible  id=mForm:lotItems0:lotItem_${index}:mozInn_panel
  \  Click Element  xpath=//div[@id='mForm:lotItems0:lotItem_${index}:mozInn_panel']//td[1]
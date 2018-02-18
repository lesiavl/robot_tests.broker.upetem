*** Settings ***

Library  String
Library  DateTime
Library  upetem_service.py
Library  get_xpath.py
Resource  subkeywords.robot
Resource  view.robot

*** Variables ***

${mail}          test_test@test.com
${bid_number}
${auction_url}

*** Keywords ***

Підготувати дані для оголошення тендера
  [Arguments]  ${username}  ${tender_data}  ${role_name}
  ${adapted_data}=  Run Keyword If  '${username}' == 'upetem_Owner'
  ...    upetem_service.adapt_data    ${tender_data}
  ...    ELSE    upetem_service.adapt_data_view    ${tender_data}
  [return]  ${adapted_data}

Підготувати клієнт для користувача
  [Arguments]  @{ARGUMENTS}
  [Documentation]  Відкрити браузер, створити об’єкт api wrapper, тощо
  ...      ${ARGUMENTS[0]} ==  username
  Open Browser   ${USERS.users['${ARGUMENTS[0]}'].homepage}   ${USERS.users['${ARGUMENTS[0]}'].browser}   alias=${ARGUMENTS[0]}
  Set Window Size   @{USERS.users['${ARGUMENTS[0]}'].size}
  Set Window Position   @{USERS.users['${ARGUMENTS[0]}'].position}
  Run Keyword If   '${ARGUMENTS[0]}' != 'upetem_Viewer'   Вхід  ${ARGUMENTS[0]}

Вхід
  [Arguments]  ${username}
  Set Selenium Timeout  60
  Wait Until Page Contains Element    xpath=//*[text()='Вхід']
  Click Element                      xpath=//*[text()='Вхід']
  Wait Until Page Contains Element   id=mForm:email
  Input text   id=mForm:email      ${USERS.users['${username}'].login}
  Input text   id=mForm:pwd      ${USERS.users['${username}'].password}
  Click Button   id=mForm:login
  Wait Until Page Contains Element  css=div.cabinet-user-name


#                                    TENDER OPERATIONS                                           #

Створити тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_data
  Set Selenium Timeout  60
  ${prepared_tender_data}=   Get From Dictionary    ${ARGUMENTS[1]}                       data

  Run Keyword If  '${mode}'=='negotiation'  Заповнити картку організації  ${ARGUMENTS[1]}

  ${items}=                  Get From Dictionary    ${prepared_tender_data}               items
  @{lots}                    Set Variable  ${prepared_tender_data.lots}
  ${lot_title}               Get From Dictionary   ${lots[0]}                             title
  ${lot_desc}                Get From Dictionary   ${lots[0]}                             description
  ${lot_value_amount}        Get From Dictionary   ${lots[0].value}                       amount
  # line below not needed for single item tender
  ${features}=  Run Keyword If  ${tender_meat}  Get From Dictionary  ${prepared_tender_data}  features
  ${title}=                  Get From Dictionary    ${prepared_tender_data}               title
  ${title_en}=  Run Keyword If  '${mode}'=='openeu'  Get From Dictionary    ${prepared_tender_data}               title_en
  ${description}=            Get From Dictionary    ${prepared_tender_data}               description
  ${description_en}=  Run Keyword If  '${mode}'=='openeu'  Get From Dictionary    ${prepared_tender_data}         description_en

  ${budget}=                 Get From Dictionary    ${prepared_tender_data.value}         amount
  ${budget}=                 upetem_service.convert_float_to_string                    ${budget}
  ${step_rate}=  Run Keyword If  '${mode}'!='negotiation'            Get From Dictionary    ${prepared_tender_data.minimalStep}   amount
  ${step_rate}=   Run Keyword If  '${mode}'!='negotiation'           upetem_service.convert_float_to_string                    ${step_rate}
  # line below not needed for open ua
  ${enquiry_period_end_date}=  Run Keyword If  '${mode}'=='belowThreshold'  upetem_service.convert_date_to_string  ${prepared_tender_data.enquiryPeriod.endDate}
  ${tender_period}=  Run Keyword If  '${mode}'!='negotiation'          Get From Dictionary   ${prepared_tender_data}                tenderPeriod
  ${tender_period_start_date}=  Run Keyword If  '${mode}'!='negotiation'  upetem_service.convert_date_to_string  ${tender_period.startDate}
  ${tender_period_end_date}=  Run Keyword If  '${mode}'!='negotiation'  upetem_service.convert_date_to_string  ${tender_period.endDate}
  ${countryName}=   Get From Dictionary   ${prepared_tender_data.procuringEntity.address}       countryName
  ${item_description}=    Get From Dictionary    ${items[0]}    description
  ${item_description_en}=  Run Keyword If  '${mode}'=='openeu'  Get From Dictionary    ${items[0]}    description_en
  ${delivery_start_date}=    Get From Dictionary    ${items[0].deliveryDate}   startDate
  ${delivery_start_date}=    upetem_service.convert_item_date_to_string    ${delivery_start_date}
  ${delivery_end_date}=      Get From Dictionary   ${items[0].deliveryDate}   endDate
  ${delivery_end_date}=      upetem_service.convert_item_date_to_string  ${delivery_end_date}
  ${item_delivery_region}=      Get From Dictionary    ${items[0].deliveryAddress}    region
  ${item_delivery_region}=     upetem_service.get_delivery_region    ${item_delivery_region}
  ${item_locality}=  Get From Dictionary  ${items[0].deliveryAddress}  locality
  ${item_delivery_address_street_address}=  Get From Dictionary  ${items[0].deliveryAddress}  streetAddress
  ${item_delivery_postal_code}=  Get From Dictionary  ${items[0].deliveryAddress}  postalCode
  ${latitude}=  Get From Dictionary  ${items[0].deliveryLocation}  latitude
  ${latitude}=  upetem_service.convert_coordinates_to_string    ${latitude}
  ${longitude}=  Get From Dictionary  ${items[0].deliveryLocation}    longitude
  ${longitude}=  upetem_service.convert_coordinates_to_string    ${longitude}
  ${cpv_id}=           Get From Dictionary   ${items[0].classification}         id
  ${cpv_id_1}=           Get Substring    ${cpv_id}   0   3
  ${dkpp_id}=        Convert To String     000
  ${code}=           Get From Dictionary   ${items[0].unit}          code
  ${quantity}=      Get From Dictionary   ${items[0]}                        quantity
  ${name}=      Get From Dictionary   ${prepared_tender_data.procuringEntity.contactPoint}       name
  ${name_en}=  Run Keyword If  '${mode}'=='openeu'  Get From Dictionary    ${prepared_tender_data.procuringEntity.contactPoint}     name_en
  Selenium2Library.Switch Browser     ${ARGUMENTS[0]}
  Wait Until Element Is Visible       xpath=//a[text()='Закупівлі']
  Click Element                       xpath=//a[text()='Закупівлі']
  Wait Until Page Contains Element    xpath=//*[text()='НОВА ЗАКУПІВЛЯ']
  Click Element                       xpath=//*[text()='НОВА ЗАКУПІВЛЯ']
  Wait Until Element Is Visible       xpath=//*[@id='mForm:procurementType_label']
  Click Element                       xpath=//*[@id='mForm:procurementType_label']
  Sleep  2
  ${procurement_type_xpath}=          get_xpath.get_procurement_type_xpath    ${mode}
  Click Element                       xpath=${procurement_type_xpath}
  Sleep  2
  Click Element                       xpath=//*[@id="mForm:chooseProcurementTypeBtn"]
  Run Keyword If  '${mode}'=='negotiation'  Wait Until Element Is Visible  jquery=.ui-icon-closethick:nth(4)
  Run Keyword If  '${mode}'=='negotiation'  Click Element  jquery=.ui-icon-closethick:nth(4)

  Wait Until Page Contains Element    id=mForm:name
  Input text                          id=mForm:name     ${title}
  Input text                          id=mForm:desc     ${description}
  Click Element                       id=mForm:cKind_label
  Sleep  2
  Click Element                       xpath=//div[@id='mForm:cKind_panel']//li[3]
  Input text                          id=mForm:lotBudg0   ${budget}
  Input text                          id=mForm:lotTitle0  ${lot_title}
  Input text                          id=mForm:lotDesc0   ${lot_desc}
  ${vat_selector}=  Set Variable If  ${NUMBER_OF_LOTS}==0  mForm:vat  mForm:lotVat0
  Run Keyword If  '${mode}'!='negotiation'  Click Element                       xpath=//*[@id='${vat_selector}']/tbody/tr/td[1]//div[2]
  ${step_selector}=  Set Variable If  ${NUMBER_OF_LOTS}==0  mForm:step  mForm:lotStep0

  # two lines below not needed for open ua
  Run Keyword If  '${mode}'=='belowThreshold'  Input text  xpath=//*[@id="mForm:dEA_input"]  ${enquiry_period_end_date}
  Run Keyword If  '${mode}'=='belowThreshold'  Input text  xpath=//*[@id="mForm:dSPr_input"]  ${tender_period_start_date}
  Run Keyword If  '${mode}'!='negotiation'  Input text                          xpath=//*[@id="mForm:dEPr_input"]  ${tender_period_end_date}
  Input text                          id=mForm:cCpvGrL_input      ${cpv_id_1}
  Wait Until Element Is Visible       xpath=.//*[@id='mForm:cCpvGrL_panel']/table/tbody/tr/td[2]/span
  Click Element                       xpath=.//*[@id='mForm:cCpvGrL_panel']/table/tbody/tr/td[2]/span

  Run Keyword If  ${tender_meat}  upetem.Додати неціновий показник на тендер  ${features}

  Input text                          id=mForm:lotItems0:lotItem_0:cCpv_input   ${cpv_id}
  Wait Until Element Is Visible       xpath=//div[@id='mForm:lotItems0:lotItem_0:cCpv_panel']//td[1]/span
  Click Element                       xpath=//div[@id='mForm:lotItems0:lotItem_0:cCpv_panel']//td[1]/span
  Sleep  5
  Run Keyword If  ${cpv_id_1}!=336   Input text  id=mForm:lotItems0:lotItem_0:cDkpp_input    ${dkpp_id}
  Input text                          id=mForm:lotItems0:lotItem_0:subject    ${item_description}
  Sleep  5
  Input text                          id=mForm:lotItems0:lotItem_0:unit_input    ${code}
  Wait Until Element Is Visible       xpath=//div[@id='mForm:lotItems0:lotItem_0:unit_panel']//tr/td[1]
  Click Element                       xpath=//div[@id='mForm:lotItems0:lotItem_0:unit_panel']//tr/td[1]
  Input text                          id=mForm:lotItems0:lotItem_0:amount   ${quantity}
  Input Text                          xpath=//*[@id='mForm:lotItems0:lotItem_0:delDS_input']  ${delivery_start_date}
  Input text                          xpath=//*[@id="mForm:lotItems0:lotItem_0:delDE_input"]  ${delivery_end_date}
  Click Element                       xpath=//*[@id="mForm:lotItems0:lotItem_0:cReg"]/div[3]
  Sleep  5
  Click Element                       xpath=//ul[@id='mForm:lotItems0:lotItem_0:cReg_items']/li[text()='${item_delivery_region}']
  Sleep  5
  Wait Until Keyword Succeeds  3x  1  Input Text  xpath=//*[@id="mForm:lotItems0:lotItem_0:cTer_input"]    ${item_locality}
  Wait Until Element Is Visible       xpath=//*[@id='mForm:lotItems0:lotItem_0:cTer']//td[1]
  Press Key                           //*[@id="mForm:lotItems0:lotItem_0:cTer_input"]    \\13
  Input text                          id=mForm:lotItems0:lotItem_0:zc  ${item_delivery_postal_code}
  Input text                          xpath=//*[@id="mForm:lotItems0:lotItem_0:delAdr"]  ${item_delivery_address_street_address}
  Input text                          id=mForm:lotItems0:lotItem_0:delLoc1  ${latitude}
  Input text                          id=mForm:lotItems0:lotItem_0:delLoc2  ${longitude}

  Run Keyword If  ${lot_meat}   upetem.Додати неціновий показник на лот  ${EMPTY}  ${EMPTY}  ${features}  ${EMPTY}
  Run Keyword If  ${item_meat}  upetem.Додати неціновий показник на предмет  ${EMPTY}  ${EMPTY}  ${features}  ${EMPTY}

  Input text                          id=mForm:rName     ${name}
  ${telephone}  Set Variable  ${prepared_tender_data.procuringEntity.contactPoint.telephone}
  Input text                          id=mForm:rPhone    ${telephone}
  Input text                          id=mForm:rMail     ${mail}
  Run Keyword If  '${mode}' == 'openeu'  Click Element  id=mForm:rLang_label
  Run Keyword If  '${mode}' == 'openeu'  Click Element  id=mForm:rLang_2

  Run Keyword If  '${mode}' == 'negotiation'  Execute Javascript  document.getElementById("mForm:cause_btn").scrollIntoView(false)
  Run Keyword If  '${mode}'=='negotiation'  Click Element                       xpath=//*[@id='${vat_selector}']/tbody/tr/td[1]//div[2]
  Run Keyword If  '${mode}'=='negotiation'  Click Button  id=mForm:cause_btn
  ${cause}  Run Keyword If  '${mode}'=='negotiation'  Get From Dictionary  ${prepared_tender_data}  cause
  Run Keyword If  '${mode}'=='negotiation'  Click Element  xpath=//div/div/input[@value='${cause}']/../..
  Run Keyword If  '${mode}'=='negotiation'  Click Element  jquery=span:contains('Вибрати')
  Run Keyword If  '${mode}'=='negotiation'  Wait Until Page Contains Element  id=mForm:cardCause
  ${cause_description}  Run Keyword If  '${mode}' == 'negotiation'  Get From Dictionary    ${prepared_tender_data}    causeDescription
  Run Keyword If  '${mode}' == 'negotiation'  Input Text  id=mForm:cause_description  ${cause_description}

  Sleep  2
  Run Keyword if   '${mode}' == 'negotiation'  upetem.Додати предмет закупівлі в лот  ${items}
  Run Keyword If  '${mode}'!='negotiation'  Input text  id=${step_selector}  ${step_rate}
  Run Keyword If  ${cpv_id_1}==336   Ввести МНН код для всіх предметів  ${items}
  Sleep  10
  ${calculated_step}  Run Keyword If  '${mode}' == 'openeu'  Get Value  id=mForm:lotStepPercent0
  ${updated_step}  Run Keyword If  '${mode}' == 'openeu'  Evaluate  ${prepared_tender_data.value.amount}*${calculated_step}/100
  Run Keyword If  '${mode}' == 'openeu'  upetem_service.adapt_step  ${ARGUMENTS[1]}  ${updated_step}
  # Save
  Click Element                       xpath=//*[@id="mForm:bSave"]

  Wait Until Element Is Visible       xpath=//div[contains(@class, "ui-confirm-dialog") and @aria-hidden="false"]//span[text()='Так']
  Click Element                       xpath=//div[contains(@class, "ui-confirm-dialog") and @aria-hidden="false"]//span[text()='Так']
  #Add language
  Run Keyword If  '${mode}' == 'openeu'  subkeywords.Додати мову закупівлі  ${description_en}  ${title_en}  ${name_en}  ${lots}  ${items}  ${features}
  # Confirm in message box
  Run Keyword If  '${mode}' != 'negotiation'  Оголосити тендер

  ${wait_for}  Set Variable If  '${mode}' == 'negotiation'  Зареєстрована, необхідно оголосити  Очікування пропозицій
  :FOR    ${INDEX}    IN RANGE    1    10
  \  Sleep  10
  \  Reload Page
  \  ${bid_status}=  Get Text  xpath=//*[@id="mForm:status"]
  \  Exit For Loop If  '${bid_status}' == '${wait_for}'

  ${tender_UAid}=  Get Text           id=mForm:nBid
  ${tender_UAid}=  Get Substring  ${tender_UAid}  19
  ${Ids}       Convert To String  ${tender_UAid}
  Run keyword if   '${mode}' == 'multi'   Set Multi Ids   ${tender_UAid}

  [return]  ${Ids}


Пошук тендера по ідентифікатору
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tenderId
  ...      ${ARGUMENTS[2]} ==  id
  Switch browser   ${ARGUMENTS[0]}
  Wait Until Element Is Visible    xpath=//a[./text()="Закупівлі"]
  Click Element                    xpath=//a[./text()="Закупівлі"]
  Wait Until Element Is Visible    xpath=//div[@id='buttons']/button[1]
  Click Element                    xpath=//div[@id='buttons']/button[1]
  Input Text                       xpath=//*[@id='search-by-number']/input    ${ARGUMENTS[1]}
  Click Element                    id=mForm:search_button
  :FOR    ${INDEX}    IN RANGE    1    50
  \  ${found}  Run Keyword And Return Status  Element Should Contain  id=mForm:tenderList_content  ${ARGUMENTS[1]}
  \  Exit For Loop If  ${found}
  \  Sleep  10
  \  Click Element  id=mForm:search_button
  Sleep  5
  Wait Until Keyword Succeeds  3x  1  Click Element    xpath=//a[text()='${ARGUMENTS[1]}']/ancestor::div[1]/span[2]/a
  Wait Until Page Contains Element  id=mForm:nBid


Оновити сторінку з тендером
  [Arguments]  ${username}  ${tender_uaid}
  Selenium2Library.Switch Browser    ${username}
  Reload Page


Отримати інформацію із тендера
  [Arguments]  ${username}  ${tender_uaid}  ${fieldname}
  Selenium2Library.Switch browser   ${username}
  ${purchase_card_is_not_visible}  Run Keyword And Return Status  Page Should Not Contain  Картка закупівлі
  Run Keyword If  ${purchase_card_is_not_visible}  upetem.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Run Keyword And Return  view.Отримати інформацію про ${fieldname}


Внести зміни в тендер
  [Arguments]  ${username}  ${tender_uaid}  ${fieldname}  ${fieldvalue}
  Selenium2Library.Switch Browser    ${username}
  upetem.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Run Keyword If  '${fieldname}' == 'tenderPeriod.endDate'  subkeywords.Змінити дату  ${fieldvalue}
  Run Keyword If  '${fieldname}' == 'description'  subkeywords.Змінити опис  ${fieldvalue}
  Sleep  2
  Click Element              xpath=//*[@id="mForm:bSave"]
  Sleep  5
  Capture Page Screenshot


Завантажити документ
  [Arguments]   ${username}  ${file}  ${tender_uaid}
  Log  ${username}
  Log  ${file}
  Log  ${tender_uaid}
  upetem.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Choose File       xpath=//*[@id='mForm:docFile_input']    ${file}
  Wait Until Element Is Visible    id=mForm:docCard:docCard
  Click Element                    xpath=//*[@id="mForm:docCard:dcType_label"]
  Wait Until Element Is Visible    xpath=//*[@id="mForm:docCard:dcType_panel"]
  Click Element                    xpath=//*[@id="mForm:docCard:dcType_panel"]/div/ul/li[2]
  Sleep  2
  Click Element                    xpath=//*[@id="mForm:docCard:docCard"]/table/tfoot/tr/td/button[1]
  Sleep  20
  Input text                       id=mForm:docAdjust     Test text
  Sleep  20
  Click Element                    xpath=//*[@id="mForm:bSave"]
  Wait Until Element Is Visible    xpath=(//*[@id="primefacesmessagedlg"]/div/a)[1]
  Sleep  20
  Click Element                    xpath=(//*[@id="primefacesmessagedlg"]/div/a)[1]
  Sleep  10
  Reload Page
  Sleep  10


Set Multi Ids
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${tender_UAid}
  ${id}=           Get Text           id=mForm:nBid
  ${Ids}   Create List    ${tender_UAid}   ${id}


Отримати інформацію із документа
  [Arguments]  ${username}  ${tender_uaid}  ${doc_id}  ${field}
  Switch browser   ${username}
  upetem.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  ${field_xpath}=  get_xpath.get_document_xpath  ${field}  ${doc_id}
  Run Keyword If    '${TEST_NAME}' == 'Відображення заголовку документації до тендера'    Wait Until Keyword Succeeds  300 s  10 s    subkeywords.Wait For Document    ${field_xpath}
  ${value}=    Get Text    ${field_xpath}
  [return]  ${value}


Отримати документ
  [Arguments]  ${username}  ${tender_uaid}  ${doc_id}
  Switch Browser    ${username}
  upetem.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  ${url_doc}=    Get Element Attribute    xpath=//*[contains(text(), '${doc_id}')]@href
  ${file_name}=    Get Text    xpath=//*[contains(text(), '${doc_id}')]
  ${file_name}=    Convert To String    ${file_name}
  upetem_service.download_file    ${url_doc}    ${file_name}    ${OUTPUT_DIR}
  [return]  ${file_name}


#                                    ITEM OPERATIONS                                       #

Додати предмет закупівлі
  [Arguments]  ${items}
  Click Element  jquery=span:contains('Додати предмет')
  Wait Until Page Contains Element  id=mForm:bidItem_1:item1
  ${item_description}=    Get From Dictionary    ${items[1]}    description
  ${item_description_en}=    Get From Dictionary    ${items[1]}    description_en
  ${delivery_start_date}=    Get From Dictionary    ${items[1].deliveryDate}   startDate
  ${delivery_start_date}=    upetem_service.convert_item_date_to_string    ${delivery_start_date}
  ${delivery_end_date}=      Get From Dictionary   ${items[1].deliveryDate}   endDate
  ${delivery_end_date}=      upetem_service.convert_item_date_to_string  ${delivery_end_date}
  ${item_delivery_region}=      Get From Dictionary    ${items[1].deliveryAddress}    region
  ${item_delivery_region}=     upetem_service.get_delivery_region    ${item_delivery_region}
  ${item_locality}=  Get From Dictionary  ${items[1].deliveryAddress}  locality
  ${item_delivery_address_street_address}=  Get From Dictionary  ${items[1].deliveryAddress}  streetAddress
  ${item_delivery_postal_code}=  Get From Dictionary  ${items[1].deliveryAddress}  postalCode
  ${latitude}=  Get From Dictionary  ${items[1].deliveryLocation}  latitude
  ${latitude}=  upetem_service.convert_coordinates_to_string    ${latitude}
  ${longitude}=  Get From Dictionary  ${items[1].deliveryLocation}    longitude
  ${longitude}=  upetem_service.convert_coordinates_to_string    ${longitude}
  ${cpv_id}=           Get From Dictionary   ${items[1].classification}         id
  ${cpv_id_1}=           Get Substring    ${cpv_id}   0   3
  ${dkpp_id}=        Convert To String     000
  ${code}=           Get From Dictionary   ${items[1].unit}          code
  ${quantity}=      Get From Dictionary   ${items[1]}                        quantity

  Input text                          id=mForm:bidItem_1:cCpv_input   ${cpv_id}
  Wait Until Element Is Visible       xpath=//div[@id='mForm:bidItem_1:cCpv_panel']//td[1]/span
  Click Element                       xpath=//div[@id='mForm:bidItem_1:cCpv_panel']//td[1]/span
  Input text                          id=mForm:bidItem_1:cDkpp_input    ${dkpp_id}
  Input text                          id=mForm:bidItem_1:subject    ${item_description}
  Input text                          id=mForm:bidItem_1:unit_input    ${code}
  Wait Until Element Is Visible       xpath=//div[@id='mForm:bidItem_1:unit_panel']//tr/td[1]
  Click Element                       xpath=//div[@id='mForm:bidItem_1:unit_panel']//tr/td[1]
  Input text                          id=mForm:bidItem_1:amount   ${quantity}
  Input Text                          xpath=//*[@id='mForm:bidItem_1:delDS_input']  ${delivery_start_date}
  Input text                          xpath=//*[@id="mForm:bidItem_1:delDE_input"]  ${delivery_end_date}
  Click Element                       xpath=//*[@id="mForm:bidItem_1:cReg"]/div[3]
  Sleep  2
  Click Element                       xpath=//ul[@id='mForm:bidItem_1:cReg_items']/li[text()='${item_delivery_region}']
  Sleep  2
  Input Text                          xpath=//*[@id="mForm:bidItem_1:cTer_input"]    ${item_locality}
  Wait Until Element Is Visible       xpath=//*[@id='mForm:bidItem_1:cTer']//td[1]
  Press Key                           //*[@id="mForm:bidItem_1:cTer_input"]    \\13
  Input text                          id=mForm:bidItem_1:zc  ${item_delivery_postal_code}
  Input text                          xpath=//*[@id="mForm:bidItem_1:delAdr"]  ${item_delivery_address_street_address}
  Input text                          id=mForm:bidItem_1:delLoc1  ${latitude}
  Input text                          id=mForm:bidItem_1:delLoc2  ${longitude}


Отримати інформацію із предмету
  [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${field_name}
  Switch browser    ${username}
  Run Keyword If    '${TEST_NAME}' == 'Відображення опису номенклатури у новому лоті'    subkeywords.Switch new lot    ${username}  ${tender_uaid}
  Run Keyword If    '${TEST_NAME}' == 'Відображення опису нової номенклатури'    upetem.Пошук тендера по ідентифікатору    ${username}  ${tender_uaid}
  Run Keyword If    '${TEST_NAME}' == 'Відображення опису нової номенклатури'    Wait Until Keyword Succeeds  300 s  30s  subkeywords.Wait For NewItem    ${item_id}
  Sleep  5
  ${value}=    subkeywords.Отримати дані з поля item    ${field_name}  ${item_id}
  ${value}=    subkeywords.Адаптувати дані з поля item    ${field_name}  ${value}
  [return]    ${value}


Видалити предмет закупівлі
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_uaid
  ...      ${ARGUMENTS[2]} ==  item_id
  ...      ${ARGUMENTS[3]} ==  lot_id

  Fail    "Драйвер не реалізовано"
  Switch browser    ${ARGUMENTS[0]}


#                                    LOT OPERATIONS                                         #

Створити лот
  [Arguments]  ${username}  ${tender_uaid}  ${lot}
  Fail    "Драйвер не реалізовано"
  Switch browser    ${username}


Створити лот із предметом закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${lot}  ${item}
  Fail    "Драйвер не реалізовано"
  Switch browser    ${username}


Отримати інформацію із лоту
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${field_name}
  Switch browser    ${username}
  ${status}=    Run Keyword And Return Status    Page Should Contain Element    xpath=//*[contains(@value, '${lot_id}')]
  Run Keyword if    '${status}' == 'False'    Click Element    xpath=//button[contains(text(), '${lot_id}')]
  Sleep  2
  ${value}=    subkeywords.Отримати дані з поля lot    ${field_name}  ${lot_id}  ${mode}
  ${value}=    subkeywords.Адаптувати дані з поля lot    ${field_name}  ${value}
  [return]    ${value}


Змінити лот
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${fieldname}  ${fieldvalue}
  Pass Execution  non-critical, let's skip it for now
  upetem.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
  Sleep  3
  Input Text  id=mForm:lotBudg0  "${fieldvalue}"
  Sleep  15
  Wait Until Keyword Succeeds  3x  1  Click Element  id=mForm:lotStep0
  Sleep  2
  Wait Until Keyword Succeeds  3x  1  Input Text  id=mForm:lotStep0  "${fieldvalue}"
  Sleep  2
  Click Button  id=mForm:bSave
  Sleep  5


Додати предмет закупівлі в лот
  [Arguments]  ${items}
  Click Element  jquery=span:contains('Додати предмет')
  Wait Until Page Contains Element  id=mForm:lotItems0:lotItem_1:item1
  ${item_description}=    Get From Dictionary    ${items[1]}    description
  ${item_description_en}=    Get From Dictionary    ${items[1]}    description_en
  ${delivery_start_date}=    Get From Dictionary    ${items[1].deliveryDate}   startDate
  ${delivery_start_date}=    upetem_service.convert_item_date_to_string    ${delivery_start_date}
  ${delivery_end_date}=      Get From Dictionary   ${items[1].deliveryDate}   endDate
  ${delivery_end_date}=      upetem_service.convert_item_date_to_string  ${delivery_end_date}
  ${item_delivery_region}=      Get From Dictionary    ${items[1].deliveryAddress}    region
  ${item_delivery_region}=     upetem_service.get_delivery_region    ${item_delivery_region}
  ${item_locality}=  Get From Dictionary  ${items[1].deliveryAddress}  locality
  ${item_delivery_address_street_address}=  Get From Dictionary  ${items[1].deliveryAddress}  streetAddress
  ${item_delivery_postal_code}=  Get From Dictionary  ${items[1].deliveryAddress}  postalCode
  ${latitude}=  Get From Dictionary  ${items[1].deliveryLocation}  latitude
  ${latitude}=  upetem_service.convert_coordinates_to_string    ${latitude}
  ${longitude}=  Get From Dictionary  ${items[1].deliveryLocation}    longitude
  ${longitude}=  upetem_service.convert_coordinates_to_string    ${longitude}
  ${cpv_id}=           Get From Dictionary   ${items[1].classification}         id
  ${cpv_id_1}=           Get Substring    ${cpv_id}   0   3
  ${dkpp_id}=        Convert To String     000
  ${code}=           Get From Dictionary   ${items[1].unit}          code
  ${quantity}=      Get From Dictionary   ${items[1]}                        quantity

  Input text                          id=mForm:lotItems0:lotItem_1:subject    ${item_description}
  Input text                          id=mForm:lotItems0:lotItem_1:cCpv_input   ${cpv_id}
  Wait Until Element Is Visible       xpath=//div[@id='mForm:lotItems0:lotItem_1:cCpv_panel']//td[1]/span
  Click Element                       xpath=//div[@id='mForm:lotItems0:lotItem_1:cCpv_panel']//td[1]/span
  Input text                          id=mForm:lotItems0:lotItem_1:cDkpp_input    ${dkpp_id}
  Input text                          id=mForm:lotItems0:lotItem_1:unit_input    ${code}
  Wait Until Element Is Visible       xpath=//div[@id='mForm:lotItems0:lotItem_1:unit_panel']//tr/td[1]
  Click Element                       xpath=//div[@id='mForm:lotItems0:lotItem_1:unit_panel']//tr/td[1]
  Input text                          id=mForm:lotItems0:lotItem_1:amount   ${quantity}
  Input Text                          xpath=//*[@id='mForm:lotItems0:lotItem_1:delDS_input']  ${delivery_start_date}
  Input text                          xpath=//*[@id="mForm:lotItems0:lotItem_1:delDE_input"]  ${delivery_end_date}
  Click Element                       xpath=//*[@id="mForm:lotItems0:lotItem_1:cReg"]/div[3]
  Sleep  2
  Click Element                       xpath=//ul[@id='mForm:lotItems0:lotItem_1:cReg_items']/li[text()='${item_delivery_region}']
  Sleep  2
  Input Text                          xpath=//*[@id="mForm:lotItems0:lotItem_1:cTer_input"]    ${item_locality}
  Wait Until Element Is Visible       xpath=//*[@id='mForm:lotItems0:lotItem_1:cTer']//td[1]
  Press Key                           //*[@id="mForm:lotItems0:lotItem_1:cTer_input"]    \\13
  Input text                          id=mForm:lotItems0:lotItem_1:zc  ${item_delivery_postal_code}
  Input text                          xpath=//*[@id="mForm:lotItems0:lotItem_1:delAdr"]  ${item_delivery_address_street_address}
  Input text                          id=mForm:lotItems0:lotItem_1:delLoc1  ${latitude}
  Input text                          id=mForm:lotItems0:lotItem_1:delLoc2  ${longitude}


Завантажити документ в лот
    [Arguments]    ${username}    ${filepath}    ${TENDER_UAID}    ${lot_id}
    upetem.Пошук тендера по ідентифікатору    ${username}    ${TENDER_UAID}
    Choose File       xpath=//*[@id='mForm:docFile_input']    ${filepath}
    Wait Until Element Is Visible    xpath=//*[text()='Картка документу']
    Click Element                    xpath=//*[@id="mForm:docCard:dcType_label"]
    Wait Until Element Is Visible    xpath=//*[@id="mForm:docCard:dcType_panel"]
    Click Element                    xpath=//*[@id="mForm:docCard:dcType_panel"]/div/ul/li[2]
    Sleep  3
    Input Text  xpath=//div[@id="mForm:docCard:docCard"]//tr[5]//textarea  Тестовий опис
    Click Element  xpath=//div[@id="mForm:docCard:docCard"]/table//tr[7]//td[2]//label
    Wait Until Element Is Visible  xpath=//div[@id="mForm:docCard:docCard"]//tr[7]//td[2]//ul
    Click Element  xpath=//div[@id="mForm:docCard:docCard"]//tr[7]//td[2]//li[contains(.,"${lot_id}")]
    Sleep  3
    Click Element                    xpath=//*[@id="mForm:docCard:docCard"]/table/tfoot/tr/td/button[1]
    Sleep  20
    Input text                       id=mForm:docAdjust     Додано тестовий документ для лоту
    Sleep  20
    Click Element                    xpath=//*[@id="mForm:bSave"]
    Sleep  20
    Wait Until Element Is Visible    xpath=(//*[@id="primefacesmessagedlg"]/div/a)[1]
    Sleep  10
    Click Element                    xpath=(//*[@id="primefacesmessagedlg"]/div/a)[1]
    Sleep  10
    Reload Page
    Sleep  10


Видалити лот
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}
  Fail    "Драйвер не реалізовано"
  Switch browser    ${username}


Скасувати лот
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${cancellation_reason}  ${document}  ${description}
  Fail    "Драйвер не реалізовано"
  Switch browser    ${username}


Отримати інформацію з документа до лоту
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${doc_id}  ${field}
  Fail    "Драйвер не реалізовано"
  Switch browser    ${username}


Отримати документ до лоту
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${doc_id}
  ${file_name}=    upetem.Отримати документ    ${username}  ${tender_uaid}  ${doc_id}
  [return]  ${file_name}


#                                    FEATURES OPERATIONS                                    #

Додати неціновий показник на тендер
  [Arguments]  ${features}
  Click Element  xpath=//*[@id='mForm:meatpanel']//span
  Sleep  10
  Execute Javascript  document.getElementById("mForm:meatpanel").scrollIntoView(false)
  Input Text  xpath=//*[@id='mForm:meatpanel']//input  ${features[1].title}
  Input Text  xpath=//*[@id='mForm:meatpanel']//textarea  ${features[1].description}
  ${i}  Set Variable  ${0}
  :FOR    ${index}  ${element}    IN ENUMERATE  @{features[1].enum}
  \  Run Keyword If  ${index} > 0  Click Element  css=.ui-datatable-header.ui-widget-header.ui-corner-top button
  \  Run Keyword If  ${index} > 0  Wait Until Page Contains Element  jquery=.ui-datatable-tablewrapper td:nth(${i})
  \  Click Element  jquery=.ui-datatable-tablewrapper td:nth(${i})
  \  Input Text  jquery=.ui-datatable-tablewrapper td:nth(${i}) input  ${element.title}
  \  Click Element  jquery=.ui-datatable-tablewrapper td:nth(${i+1})
  \  Input Text     jquery=.ui-datatable-tablewrapper td:nth(${i+1}) input  Тестовий коментар
  \  Click Element  jquery=.ui-datatable-tablewrapper td:nth(${i+2})
  \  ${value}  Evaluate  int(${element.value}*100)
  \  Press Key  css=div.ui-cell-editor-input[style='display: block;'] input  \\127  # necessary workaround
  \  Input Text     jquery=.ui-datatable-tablewrapper td:nth(${i+2}) input  ${value}
  \  ${i}  Set Variable  ${i+4}


Додати неціновий показник на предмет
  [Arguments]  ${username}  ${tender_uaid}  ${features}  ${item_id}
  ${f_var}  Set Variable If  '${TEST_NAME}' == 'Можливість додати неціновий показник на перший предмет'  ${features}  ${features[2]}
  ${num}  Set Variable If  '${TEST_NAME}' == 'Можливість додати неціновий показник на перший предмет'  3  2
  ${scroll}  Set Variable If  '${TEST_NAME}' == 'Можливість додати неціновий показник на перший предмет'  4830  4300
  Execute Javascript  window.scrollTo(0,3300)
  Sleep  1
  Click Element  jquery=span:contains('Додати показник'):nth(1)
  Wait Until Page Contains Element  xpath=//div[@id='mForm:lotItems0:meatDataLot0']/table[${num}]//input
  Execute Javascript  window.scrollTo(0,${scroll})
  Sleep  1
  Input Text  xpath=//div[@id='mForm:lotItems0:meatDataLot0']/table[${num}]//input  ${f_var.title}
  Input Text  xpath=//div[@id='mForm:lotItems0:meatDataLot0']/table[${num}]//textarea  ${f_var.description}
  Click Element  xpath=//div[@id='mForm:lotItems0:meatDataLot0']/table[${num}]//tr[3]//div
  Click Element  xpath=//div[@id='mForm:lotItems0:meatDataLot0']/table[${num}]//tr[3]//div[@class='ui-selectonemenu-items-wrapper']/ul/li[2]
  ${i}  Set Variable  ${0}
  :FOR    ${index}  ${element}    IN ENUMERATE  @{f_var.enum}
  \  Run Keyword If  ${index} > 0  Click Element  jquery=.ui-datatable-header.ui-widget-header.ui-corner-top:nth(${num}) button
  \  Run Keyword If  ${index} > 0  Wait Until Page Contains Element  jquery=.ui-datatable-tablewrapper:nth(${num}) td:nth(${i})
  \  Click Element  jquery=.ui-datatable-tablewrapper:nth(${num}) td:nth(${i})
  \  Input Text     jquery=.ui-datatable-tablewrapper:nth(${num}) td:nth(${i}) input  ${element.title}
  \  Click Element  jquery=.ui-datatable-tablewrapper:nth(${num}) td:nth(${i+1})
  \  Input Text     jquery=.ui-datatable-tablewrapper:nth(${num}) td:nth(${i+1}) input  Тестовий коментар
  \  Click Element  jquery=.ui-datatable-tablewrapper:nth(${num}) td:nth(${i+2})
  \  ${value}  Evaluate  int(${element.value}*100)
  \  Press Key  css=div.ui-cell-editor-input[style='display: block;'] input  \\127  # necessary workaround
  \  Input Text     jquery=.ui-datatable-tablewrapper:nth(${num}) td:nth(${i+2}) input  ${value}
  \  ${i}  Set Variable  ${i+4}
  Run Keyword If  '${TEST_NAME}' == 'Можливість додати неціновий показник на перший предмет'  Click Element  id=mForm:bSave
  Sleep  10


Додати неціновий показник на лот
  [Arguments]  ${username}  ${tender_uaid}  ${features}  ${lot_id}
  Execute Javascript  window.scrollTo(0,3300)
  Sleep  1
  Click Element  xpath=//div[@id='mForm:lotItems0']//span[text()='Додати показник']
  Sleep  10
  ${iter_items}  Set Variable If  '${TEST_NAME}' == 'Можливість додати неціновий показник на перший лот'  ${features}  ${features[0]}
  ${num}  Set Variable If  '${TEST_NAME}' == 'Можливість додати неціновий показник на перший лот'  3  1
  Wait Until Page Contains Element  xpath=(//div[@id='mForm:lotItems0:meatDataLot0']//input[contains(@id,'meatTitle')])[${num}]
  Input Text  xpath=(//div[@id='mForm:lotItems0:meatDataLot0']//input[contains(@id,'meatTitle')])[${num}]  ${iter_items.title}
  Input Text  xpath=(//div[@id='mForm:lotItems0:meatDataLot0']//textarea[contains(@id,'meat_comment')])[${num}]  ${iter_items.description}
  ${i}  Set Variable  ${0}
  :FOR    ${index}  ${element}    IN ENUMERATE  @{iter_items.enum}
  \  Run Keyword If  ${index} > 0  Click Element  jquery=.ui-datatable-header.ui-widget-header.ui-corner-top:nth(${num}) button
  \  Run Keyword If  ${index} > 0  Wait Until Page Contains Element  jquery=.ui-datatable-tablewrapper:nth(${num}) td:nth(${i})
  \  Click Element  jquery=.ui-datatable-tablewrapper:nth(${num}) td:nth(${i})
  \  Input Text     jquery=.ui-datatable-tablewrapper:nth(${num}) td:nth(${i}) input  ${element.title}
  \  Click Element  jquery=.ui-datatable-tablewrapper:nth(${num}) td:nth(${i+1})
  \  Input Text     jquery=.ui-datatable-tablewrapper:nth(${num}) td:nth(${i+1}) input  Тестовий коментар
  \  Click Element  jquery=.ui-datatable-tablewrapper:nth(${num}) td:nth(${i+2})
  \  ${value}  Evaluate  int(${element.value}*100)
  \  Press Key  css=div.ui-cell-editor-input[style='display: block;'] input  \\127  # necessary workaround
  \  Input Text     jquery=.ui-datatable-tablewrapper:nth(${num}) td:nth(${i+2}) input  ${value}
  \  ${i}  Set Variable  ${i+4}
  Run Keyword If  '${TEST_NAME}' == 'Можливість додати неціновий показник на перший лот'  Click Element  id=mForm:bSave
  Sleep  10


Отримати інформацію із нецінового показника
  [Arguments]  ${username}  ${tender_uaid}  ${feature_id}  ${field_name}
  Switch browser    ${username}
  Run Keyword If    '${TEST_NAME}' == 'Відображення заголовку нецінового показника на предмет'    upetem.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Run Keyword If    '${TEST_NAME}' == 'Відображення заголовку нецінового показника на тендер'    upetem.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Run Keyword If    '${TEST_NAME}' == 'Відображення заголовку нецінового показника на лот'    upetem.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Run Keyword If    '${TEST_NAME}' == 'Відображення заголовку нецінового показника на предмет'    Wait Until Keyword Succeeds  300 s  10 s  subkeywords.Wait For NewFeature  ${feature_id}
  Run Keyword If    '${TEST_NAME}' == 'Відображення заголовку нецінового показника на тендер'    Wait Until Keyword Succeeds  300 s  10 s  subkeywords.Wait For NewFeature  ${feature_id}
  Run Keyword If    '${TEST_NAME}' == 'Відображення заголовку нецінового показника на лот'    Wait Until Keyword Succeeds  300 s  10 s  subkeywords.Wait For NewFeature  ${feature_id}
  Sleep  3
  ${value}=    subkeywords.Отримати дані з поля feature    ${field_name}  ${feature_id}
  ${value}=  Run Keyword If  '${field_name}' == 'featureOf'    upetem_service.convert_data_feature  ${value}
  ...        ELSE    Set Variable    ${value}
  [return]  ${value}


Видалити неціновий показник
  [Arguments]  @{ARGUMENTS}
  Execute Javascript  window.scrollTo(0,4300)
  Click Element  xpath=//div[@id='mForm:lotItems0:meatDataLot0']/table[3]//td/button
  Wait Until Page Does Not Contain Element  xpath=//div[@id='mForm:lotItems0:meatDataLot0']/table[3]//td/button
  Click Element  id=mForm:bSave
  Wait Until Element Is Visible  id=notifyMess


#                                    QUESTION                                               #

Задати запитання на тендер
  [Arguments]  ${username}  ${tender_uaid}  ${question}

  ${title}=         Get From Dictionary   ${question.data}   title
  ${description}=   Get From Dictionary   ${question.data}   description

  Selenium2Library.Switch Browser    ${username}
  Sleep  5
  upetem.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
  Wait Until Element Is Visible       xpath=//span[./text()='Обговорення']
  Click Element                       xpath=//span[./text()='Обговорення']
  Input Text                          xpath=//*[@id="mForm:messT"]  ${title}
  Input Text                          xpath=//*[@id="mForm:messQ"]  ${description}
  Sleep  5
  Click Element                       xpath=//*[@id="mForm:btnQ"]
  Sleep  30

Задати запитання на предмет
  [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${question}

  ${title}=         Get From Dictionary   ${question.data}   title
  ${description}=   Get From Dictionary   ${question.data}   description

  Selenium2Library.Switch Browser    ${username}
  Sleep  5
  upetem.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
  Wait Until Element Is Visible       xpath=//span[./text()='Обговорення']
  Click Element                       xpath=//span[./text()='Обговорення']
  Wait Until Element Is Visible       xpath=//*[@id='mForm:questTo_label']
  Click Element                       xpath=//*[@id='mForm:questTo_label']
  Sleep  2
  Click Element                       xpath=(//*[contains(text(), 'Предмет закупівлі')])[2]
  Input Text                          xpath=//*[@id='mForm:messT']    ${title}
  Input Text                          xpath=//*[@id='mForm:messQ']    ${description}
  Sleep  5
  Click Element                       xpath=//*[@id='mForm:btnQ']
  Sleep  30


Задати запитання на лот
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${question}

  ${title}=         Get From Dictionary   ${question.data}   title
  ${description}=   Get From Dictionary   ${question.data}   description

  Selenium2Library.Switch Browser    ${username}
  Sleep  5
  upetem.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
  Wait Until Element Is Visible        xpath=//span[./text()='Обговорення']
  Click Element                        xpath=//span[./text()='Обговорення']
  Wait Until Element Is Visible       xpath=//*[@id='mForm:questTo_label']
  Click Element                       xpath=//*[@id='mForm:questTo_label']
  Sleep  2
  Click Element                       xpath=(//*[@id='mForm:questTo_panel']//*[contains(text(), '${lot_id}')])[1]
  Input Text                          xpath=//*[@id='mForm:messT']    ${title}
  Input Text                          xpath=//*[@id='mForm:messQ']    ${description}
  Sleep  5
  Click Element                       xpath=//*[@id='mForm:btnQ']
  Sleep  30


Отримати інформацію із запитання
  [Arguments]  ${username}  ${tender_uaid}  ${question_id}  ${field_name}
  Selenium2Library.Switch browser   ${username}
  upetem.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Click Element      xpath=//span[text()='Обговорення']
  ${field_xpath}=    get_xpath.get_question_xpath    ${field_name}    ${question_id}
  Wait Until Keyword Succeeds    300 s    10 s    subkeywords.Wait For Question    ${field_xpath}
  ${value}=    Get Text    xpath=${field_xpath}
  [return]  ${value}

Відповісти на запитання
  [Arguments]  ${username}  ${tender_uaid}  ${answer_data}  ${question_id}
  ${answer}=     Get From Dictionary    ${answer_data.data}    answer
  Selenium2Library.Switch Browser    ${username}
  upetem.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Wait Until Element Is Visible    xpath=//*[@id="mForm:status"]
  ${tender_status}=    Get Text    xpath=//*[@id="mForm:status"]
  Click Element                      xpath=//span[./text()='Обговорення']
  Sleep  3
  Click Element                      xpath=//span[contains(text(), '${question_id}')]/ancestor::div[@id='mForm:data_content']//button
  Input Text    xpath=//*[@id="mForm:messT"]    "Test answer"
  Input Text    xpath=//*[@id="mForm:messQ"]    ${answer}
  Sleep  2
  Click Element                      xpath=//*[@id="mForm:btnR"]
  Wait Until Element Is Visible  id=notifyMess
  Element Should Contain  id=notifyMess  Збережено!

#                                CLAIMS                                 #

Створити чернетку вимоги про виправлення умов закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${claim}
  upetem.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
  Click Element    xpath=//*[text()='Вимоги']
  Sleep  5
  Click Element    xpath=//span[text()='Нова вимога']
  Sleep  2
  Input Text    xpath=//*[@id='mForm:data:title']    ${claim.data.title}
  Sleep  2
  Input Text    xpath=//*[@id='mForm:data:description']    ${claim.data.description}
  Sleep  2
  Click Element    xpath=//span[text()='Зареєструвати']
  Sleep  10
  ${complaintID}    upetem_service.convert_complaintID    ${tender_uaid}    tender
  [return]  ${complaintID}

Створити чернетку вимоги про виправлення умов лоту
  [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${lot_id}
  upetem.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
  Click Element    xpath=//*[text()='Вимоги']
  Sleep  5
  Click Element    xpath=//span[text()='Нова вимога']
  Sleep  2
  Input Text    xpath=//*[@id='mForm:data:title']    ${claim.data.title}
  Sleep  2
  Input Text    xpath=//*[@id='mForm:data:description']    ${claim.data.description}
  Sleep  2
  Click Element    xpath=//span[text()='Зареєструвати']
  Sleep  10
  ${complaintID}    upetem_service.convert_complaintID    ${tender_uaid}    lot
  [return]  ${complaintID}

Створити чернетку про виправлення умов лоту
  [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${lot_id}
  Fail    "Драйвер не реалізовано"
  Switch browser    ${username}


Створити чернетку вимоги про виправлення визначення переможця
  [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${award_index}
  Run Keyword And Return  upetem.Створити вимогу про виправлення визначення переможця  ${username}  ${tender_uaid}  ${claim}  ${award_index}


Створити вимогу про виправлення умов закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${document}=${None}
  upetem.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
  Run Keyword If    '${mode}' != 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги та скарги']
  Run Keyword If    '${mode}' == 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги']
  Sleep  5
  Click Element    xpath=//span[text()='Нова вимога']
  Sleep  5
  Input Text    xpath=//*[@id='mForm:data:title']    ${claim.data.title}
  Sleep  2
  Input Text    xpath=//*[@id='mForm:data:description']    ${claim.data.description}
  Sleep  2
  Run Keyword If    '${document}' != '${None}'    Choose File    xpath=//*[text()='Завантажити документ']//ancestor::div[1]//input    ${document}

  Click Element    xpath=//span[text()='Зареєструвати']
  Sleep  10
  ${type}=  Set Variable If    'закупівлі' in '${TEST_NAME}'    tender
  ...                          'лоту' in '${TEST_NAME}'    lot
  ${complaintID}=    upetem_service.convert_complaintID    ${tender_uaid}    ${type}
  [return]  ${complaintID}


Створити вимогу про виправлення умов лоту
  [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${lot_id}  ${document}=${None}
  upetem.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
  Run Keyword If    '${mode}' != 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги та скарги']
  Run Keyword If    '${mode}' == 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги']
  Sleep  5
  Click Element    xpath=//span[text()='Нова вимога']
  Sleep  5
  Input Text    xpath=//*[@id='mForm:data:title']    ${claim.data.title}
  Sleep  2
  Input Text    xpath=//*[@id='mForm:data:description']    ${claim.data.description}
  Sleep  2
  Run Keyword If    '${document}' != '${None}'    Choose File    xpath=//*[text()='Завантажити документ']//ancestor::div[1]//input    ${document}

  Click Element    xpath=//span[text()='Зареєструвати']
  Sleep  10
  ${type}=  Set Variable If    'закупівлі' in '${TEST_NAME}'    tender
  ...                          'лоту' in '${TEST_NAME}'    lot
  ${complaintID}=    upetem_service.convert_complaintID    ${tender_uaid}    ${type}
  [return]  ${complaintID}


Створити вимогу про виправлення визначення переможця
  [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${award_index}  ${document}=${None}
  upetem.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Execute Javascript  window.scrollTo(0,1100)
  Click Element  jquery=span:contains('Результати аукціону')
  Sleep  5
  Click Element  jquery=span:contains('Учасники аукціону')
  Sleep  5
  :FOR    ${INDEX}    IN RANGE    1    12
  \  ${visible}  Run Keyword And Return Status  Element Should Be Visible  jquery=span:contains('Перегляд оцінки')
  \  Exit For Loop If  ${visible}
  \  Sleep  10
  \  Reload Page
  Click Element  jquery=span:contains('Перегляд оцінки')
  Sleep  5
  Click Element  jquery=span:contains('Нова вимога')
  Sleep  5
  Input Text    xpath=//*[@id='mForm:data:title']    ${claim.data.title}
  Sleep  2
  Input Text    xpath=//*[@id='mForm:data:description']    ${claim.data.description}
  Sleep  2
  Run Keyword If    '${document}' != '${None}'    Choose File    xpath=//*[text()='Завантажити документ']//ancestor::div[1]//input    ${document}
  Click Element    xpath=//span[text()='Зареєструвати']
  Sleep  10
  ${complaintID}  upetem_service.convert_complaintID    ${tender_uaid}    tender
  [return]  ${complaintID}


Завантажити документацію до вимоги
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${document}
  upetem.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
  Click Element    xpath=//span[text()='Вимоги та скарги']
  Wait Until Element Is Visible    xpath=//*[text()='${complaintID}']
  Click Element    //*[text()='${complaintID}']


Завантажити документацію до вимоги про виправлення визначення переможця
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${award_index}  ${document}
  Fail    "Драйвер не реалізовано"
  Switch browser    ${username}


Подати вимогу
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${confirmation_data}
  Fail    "Драйвер не реалізовано"
  Switch browser    ${username}


Подати вимогу про виправлення визначення переможця
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${award_index}  ${confirmation_data}
  Fail    "Драйвер не реалізовано"
  Switch browser    ${username}


Відповісти на вимогу про виправлення умов закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${answer_data}
  Switch browser    ${username}
  upetem.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
  Click Element  jquery=span:contains("Вимоги")
  ${complaint_number}  Evaluate  ${complaintID.split('.')[1][1:]}-1
  Wait Until Element Is Visible  id=mForm:data_data
  :FOR    ${INDEX}    IN RANGE    1    12
  \  ${complaint is visible}  Run Keyword And Return Status  Element Should Be Visible  id=mForm:data:${complaint_number}:NBid
  \  Exit For Loop If  ${complaint is visible}
  \  Sleep  15
  \  Reload Page
  Click Element  xpath=(//td/a[@id='mForm:data:0:NBid']/ancestor::tr/td/a)[1]
  Wait Until Element Is Visible  id=mForm:data:resolutionType_label
  Click Element  id=mForm:data:resolutionType_label
  ${resolution_id}  Set Variable If
  ...  '${answer_data.data.resolutionType}'=='resolved'  mForm:data:resolutionType_0
  ...  '${answer_data.data.resolutionType}'=='invalid'   mForm:data:resolutionType_1
  ...  '${answer_data.data.resolutionType}'=='declined'  mForm:data:resolutionType_2
  Click Element  id=${resolution_id}
  Input Text  id=mForm:data:resolution  ${answer_data.data.resolution}
  Click Element  jquery=span:contains("Зареєструвати відповідь")
  Wait Until Element Is Visible  id=notifyMess
  Element Should Contain  id=notifyMess  Збережено!


Відповісти на вимогу про виправлення умов лоту
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${answer_data}
  Fail    "Драйвер не реалізовано"
  Switch browser    ${username}


Відповісти на вимогу про виправлення визначення переможця
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${answer_data}  ${award_index}
  upetem.Відповісти на вимогу про виправлення умов закупівлі  ${username}  ${tender_uaid}  ${complaintID}  ${answer_data}


Підтвердити вирішення вимоги про виправлення умов закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${confirmation_data}
  upetem.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
  Run Keyword If    '${mode}' != 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги та скарги']
  Run Keyword If    '${mode}' == 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги']
  Sleep  2
  Click Element    xpath=(//*[@id='mForm:data_data']/tr/td[1]/a)[1]
  Sleep  2
  ${option}  Set Variable If  ${confirmation_data.data.satisfied}  Погодитись з відповіддю  Не погодитись з відповіддю
  Click Element    xpath=//*[text()='${option}']
  Sleep  2
  Capture Page Screenshot
  Sleep  30
  Reload Page
  Sleep  30


Підтвердити вирішення вимоги про виправлення умов лоту
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${confirmation_data}
  upetem.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
  Run Keyword If    '${mode}' != 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги та скарги']
  Run Keyword If    '${mode}' == 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги']
  Sleep  2
  Click Element    xpath=(//*[@id='mForm:data_data']/tr/td[1]/a)[1]
  Sleep  2
  ${option}  Set Variable If  ${confirmation_data.data.satisfied}  Погодитись з відповіддю  Не погодитись з відповіддю
  Click Element    xpath=//*[text()='${option}']
  Sleep  2
  Capture Page Screenshot
  Sleep  30
  Reload Page
  Sleep  30


Підтвердити вирішення вимоги про виправлення визначення переможця
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${confirmation_data}  ${award_index}
  upetem.Підтвердити вирішення вимоги про виправлення умов закупівлі  ${username}  ${tender_uaid}  ${complaintID}  ${confirmation_data}


Скасувати вимогу про виправлення умов закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${cancellation_data}
  upetem.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
  Click Element    xpath=//span[text()='Вимоги']
  Sleep  2
  Click Element    xpath=(//*[@id='mForm:data_data']/tr/td[1]/a)[1]
  Sleep  2
  Input Text    xpath=//*[@id='mForm:data:cancellationReason']    ${cancellation_data.data.cancellationReason}
  Execute JavaScript  window.scrollTo(0,0)
  Click Element    xpath=//*[text()='Відмінити вимогу']
  Sleep  5


Скасувати вимогу про виправлення умов лоту
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${cancellation_data}
  upetem.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
  Click Element    xpath=//span[text()='Вимоги']
  Sleep  2
  Click Element    xpath=(//*[@id='mForm:data_data']/tr/td[1]/a)[1]
  Sleep  2
  Input Text    xpath=//*[@id='mForm:data:cancellationReason']    ${cancellation_data.data.cancellationReason}
  Execute JavaScript  window.scrollTo(0,0)
  Click Element    xpath=//*[text()='Відмінити вимогу']
  Sleep  5


Скасувати вимогу про виправлення визначення переможця
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${cancellation_data}  ${award_index}
  upetem.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
  Sleep  10
  Click Element    xpath=//span[text()='Вимоги']
  Sleep  10
  Reload Page
  Sleep  10
  Click Element    xpath=(//*[@id='mForm:data_data']/tr/td[1]/a)[1]
  Sleep  5
  Input Text    xpath=//*[@id='mForm:data:cancellationReason']    ${cancellation_data.data.cancellationReason}
  Execute JavaScript  window.scrollTo(0,0)
  Click Element    xpath=//*[text()='Відмінити вимогу']
  Sleep  5


Перетворити вимогу про виправлення умов закупівлі в скаргу
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${escalating_data}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Перетворити вимогу про виправлення умов лоту в скаргу
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${escalating_data}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Перетворити вимогу про виправлення визначення переможця в скаргу
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${escalating_data}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Отримати інформацію із скарги
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${field_name}  ${award_index}=${None}
  Selenium2Library.Switch browser   ${username}
  upetem.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Run Keyword If    '${mode}' != 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги та скарги']
  Run Keyword If    '${mode}' == 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги']
  Run Keyword If    "${TEST_NAME}" == "Відображення опису вимоги"    Wait Until Keyword Succeeds  300 s  10 s  subkeywords.Wait For ClaimTender
  Run Keyword If    "${TEST_NAME}" == "Відображення опису вимоги про виправлення умов закупівлі"    Wait Until Keyword Succeeds  300 s  10 s  subkeywords.Wait For ClaimTender
  Run Keyword If    "${TEST_NAME}" == "Відображення опису вимоги про виправлення умов лоту"    Wait Until Keyword Succeeds  300 s  10 s  subkeywords.Wait For ClaimLot
  :FOR    ${INDEX}    IN RANGE    1    12
  \  ${complaint is visible}  Run Keyword And Return Status  Element Should Be Visible  xpath=(//*[@id='mForm:data_data']/tr/td[1]/a)[1]
  \  Exit For Loop If  ${complaint is visible}
  \  Sleep  15
  \  Reload Page
  Click Element    xpath=(//*[@id='mForm:data_data']/tr/td[1]/a)[1]
  Sleep  3
  Run Keyword If    "Відображення статусу 'answered'" in "${TEST_NAME}"  Wait Until Keyword Succeeds  300 s  15 s  subkeywords.Wait For Answered
  Run Keyword If    "Відображення статусу 'cancelled'" in "${TEST_NAME}"    Wait Until Keyword Succeeds  300 s  15 s  subkeywords.Wait For Cancelled
  Run Keyword If    "Відображення статусу 'resolved'" in "${TEST_NAME}"    Wait Until Keyword Succeeds  300 s  15 s  subkeywords.Wait For Resolved
  Run Keyword If    "Відображення статусу 'ignored'" in "${TEST_NAME}"    Wait Until Keyword Succeeds  300 s  15 s  subkeywords.Wait For Ignored
  Run Keyword If    "${TEST_NAME}" == "Можливість відповісти на вимогу про виправлення умов закупівлі"    Wait Until Keyword Succeeds  420 s  15 s  subkeywords.Wait For Answered
  Run Keyword If    "${TEST_NAME}" == "Можливість відповісти на вимогу про виправлення умов лоту"    Wait Until Keyword Succeeds  420 s  15 s  subkeywords.Wait For Answered
  Run Keyword If    "${TEST_NAME}" == "Відображення задоволення вимоги"    Wait Until Keyword Succeeds  300 s  15 s  subkeywords.Wait For Satisfied
  Run Keyword If    "${TEST_NAME}" == "Відображення незадоволення вимоги"    Wait Until Keyword Succeeds  300 s  15 s  subkeywords.Wait For Satisfied
  ${field_xpath}=    get_xpath.get_claims_xpath    ${field_name}
  ${type_field}=    upetem_service.get_type_field    ${field_name}
  ${value}=  Run Keyword If    '${type_field}' == 'value'    Get Value    ${field_xpath}
  ...     ELSE IF             '${type_field}' == 'text'    Get Text    ${field_xpath}
  ${return_value}=  Run Keyword If    '${field_name}' == 'status'    upetem_service.get_claim_status    ${value}    "${TEST_NAME}"
  ...    ELSE IF                      '${field_name}' == 'resolutionType'    upetem_service.get_resolution_type    ${value}
  ...    ELSE IF                      '${field_name}' == 'satisfied'    upetem_service.convert_satisfied    ${value}
  ...    ELSE IF                      '${field_name}' == 'complaintID'    Set Variable    ${complaintID}
  ...    ELSE    Set Variable    ${value}
  [return]  ${return_value}


Отримати інформацію із документа до скарги
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${doc_id}  ${field_name}  ${award_id}=${None}
  upetem.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Run Keyword If    '${mode}' != 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги та скарги']
  Run Keyword If    '${mode}' == 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги']
  Wait Until Element Is Visible    xpath=//*[@id='mForm:data_data']/tr/td[1]/a
  Click Element    xpath=(//*[@id='mForm:data_data']/tr/td[1]/a)[1]
  Sleep  3
  ${value}=    Get Text    xpath=//*[contains(text(), '${doc_id}')]
  [return]  ${value}


Отримати документ до скарги
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${doc_id}  ${award_id}=${None}
  upetem.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Run Keyword If    '${mode}' != 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги та скарги']
  Run Keyword If    '${mode}' == 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги']
  Wait Until Element Is Visible    xpath=//*[@id='mForm:data_data']/tr/td[1]/a
  Click Element    xpath=(//*[@id='mForm:data_data']/tr/td[1]/a)[1]
  Sleep  3
  ${url_doc}=    Get Element Attribute    xpath=//*[contains(text(), '${doc_id}')]@href
  ${file_name}=    Get Text    xpath=//*[contains(text(), '${doc_id}')]
  ${file_name}=    Convert To String    ${file_name}
  upetem_service.download_file    ${url_doc}    ${file_name}    ${OUTPUT_DIR}
  [return]  ${file_name}

#                               BID OPERATIONS                          #

Подати цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}  ${bid}  ${lots_ids}=${None}  ${features_ids}=${None}
  Switch browser  ${username}
  upetem.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  ${tender_status}=  Get Text  xpath=//*[@id="mForm:status"]
  Run Keyword If  '${tender_status}' == 'Період уточнень'  Fail  "Неможливо подати цінову пропозицію в період уточнень"
  Click Element    xpath=//span[text()='Подати пропозицію']

  Run Keyword If    '${mode}' == 'belowThreshold'    subkeywords.Подати цінову пропозицію для below    ${bid}
  Run Keyword If    '${mode}' == 'openua'    subkeywords.Подати цінову пропозицію для open    ${bid}    ${lots_ids}    ${features_ids}
  Run Keyword If    '${mode}' == 'openeu'    subkeywords.Подати цінову пропозицію для open    ${bid}    ${lots_ids}    ${features_ids}

  Input Text  xpath=//*[@id="mForm:data:rName"]    Тестовий закупівельник
  Input Text  xpath=//*[@id="mForm:data:rPhone"]   +380630000000
  Input Text  xpath=//*[@id="mForm:data:rMail"]    ${mail}

  Click Element  xpath=//*[text()='Зберегти']
  Sleep  3
  Wait Until Element Is Visible    xpath=//*[@id='mForm:proposalSaveInfo']/div[3]/button
  Click Element  xpath=//*[@id='mForm:proposalSaveInfo']/div[3]/button/span[2]
  Sleep  2
  Wait Until Element Is Visible    xpath=//*[text()='Зареєструвати пропозицію']
  Click Element  xpath=//*[text()='Зареєструвати пропозицію']
  Wait Until Element Is Visible    xpath=//*[@id='mForm:cdPay']
  Click Element    xpath=//*[@id='mForm:cdPay']/div[2]/table//tr[6]/td//tr[2]/td/div
  Sleep  2
  Click Element  xpath=(//*[text()='Зареєструвати пропозицію'])[2]
  Wait Until Element Is Visible    //*[@id='mForm:data']/div[1]/table/tbody/tr[5]/td[2]
  :FOR    ${INDEX}    IN RANGE    1    11
  \  ${bid_status}=  Get Text  xpath=//*[@id='mForm:data']/div[1]/table/tbody/tr[5]/td[2]
  \  Exit For Loop If  '${bid_status}' == 'Зареєстрована'
  \  Sleep  15
  \  Reload Page


Змінити цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}  ${fieldname}  ${fieldvalue}
  upetem.Пошук цінової пропозиції  ${username}  ${tender_uaid}
  Run Keyword If    '${mode}' == 'belowThreshold'    subkeywords.Змінити цінову пропозицію below    ${fieldvalue}
  ...    ELSE IF    '${mode}' != 'belowThreshold'    subkeywords.Змінити цінову пропозицію open    ${fieldname}    ${fieldvalue}
  

Скасувати цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}
  upetem.Пошук цінової пропозиції  ${username}  ${tender_uaid}
  Click Element    xpath=//*[@id='mForm:proposalDeleteBtn']
  Click Element    xpath=//*[text='Видалити']
  Sleep  5

Завантажити документ в ставку
  [Arguments]  ${username}  ${path}  ${tender_uaid}  ${doc_type}=documents
  upetem.Пошук цінової пропозиції  ${username}  ${tender_uaid}
  Choose File       xpath=//*[@id='mForm:data:tFile_input']    ${path}
  Wait Until Element Is Visible    xpath=//*[@id='mForm:docCard:dcType_label']
  Click Element    xpath=//*[@id='mForm:docCard:dcType_label']
  Sleep  2
  Click Element    xpath=//*[@id="mForm:docCard:dcType_panel"]/div/ul/li[2]
  Sleep  2
  Click Element  xpath=//*[@id="mForm:docCard:docCard"]/table/tfoot/tr/td/button[1]
  Sleep  20
  Click Element    xpath=//*[text()='Зберегти']
  Sleep  25


Змінити документ в ставці
  [Arguments]  ${username}  ${tender_uaid}  ${path}  ${doc_id}
  upetem.Пошук цінової пропозиції  ${username}  ${tender_uaid}
  Execute JavaScript                  window.scrollTo(0, 1000)
  Sleep  2
  Click Element    xpath=//a[contains(text(), '${doc_id}')]//ancestor::tr/td[6]/button[1]/span[1]
  Sleep  10
  Choose File       xpath=//*[@id='mForm:data:tFile_input']    ${path}
  Wait Until Element Is Visible    xpath=//*[@id='mForm:docCard:dcType_label']
  Sleep  2
  Click Element    xpath=//*[@id='mForm:docCard:dcType_label']
  Wait Until Element Is Visible  xpath=//*[@id="mForm:docCard:dcType_panel"]/div/ul/li[2]
  Click Element    xpath=//*[@id="mForm:docCard:dcType_panel"]/div/ul/li[2]
  Sleep  2
  Click Element  xpath=//*[@id="mForm:docCard:docCard"]/table/tfoot/tr/td/button[1]
  Sleep  20
  Click Element    xpath=//*[text()='Зберегти']
  Sleep  25


Змінити документацію в ставці
  [Arguments]  ${username}  ${tender_uaid}  ${doc_data}  ${doc_id}
  upetem.Пошук цінової пропозиції  ${username}  ${tender_uaid}
  Execute JavaScript                  window.scrollTo(0, 800)
  Sleep  2
  Click Element    xpath=//a[contains(text(), '${doc_id}')]//ancestor::tr/td[6]/button[1]/span[1]
  Wait Until Element Is Visible    xpath=//*[text()= 'Картка документу']
  Click Element    xpath=//*[@id='mForm:docCard:dcType_label']
  Sleep  2
  Click Element    xpath=//*[@id="mForm:docCard:dcType_panel"]/div/ul/li[3]
  Sleep  2
  Click Element  xpath=//*[@id="mForm:docCard:docCard"]/table/tfoot/tr/td/button[1]
  Sleep  20
  Click Element    xpath=//*[text()='Зберегти']
  Sleep  25


Отримати інформацію із пропозиції
  [Arguments]  ${username}  ${tender_uaid}  ${field}
  upetem.Пошук цінової пропозиції  ${username}  ${tender_uaid}
  Run Keyword If    "${TEST_NAME}" == "Відображення зміни статусу першої пропозиції після редагування інформації про тендер"    Wait Until Keyword Succeeds  420 s  15 s  subkeywords.Wait For Status
  ${return_value}=    Run Keyword If    '${mode}' == 'belowThreshold'    subkeywords.Отримати дані з bid below
  ...    ELSE IF                      '${mode}' != 'belowThreshold'    subkeywords.Отримати дані з bid open    ${field}
  [return]  ${return_value}


Отримати посилання на аукціон для учасника
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}=${Empty}
  Selenium2Library.Switch Browser    ${username}
  upetem.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Wait Until Element Is Visible    xpath=//*[contains(@onclick, 'https://auction-sandbox.openprocurement.org/tenders/')]
  Sleep  2
  ${auction_url}=    Get Element Attribute    xpath=//*[contains(@onclick, 'https://auction-sandbox.openprocurement.org/tenders/')]@onclick
  ${url}=    Get Substring    ${auction_url}    13    97
  [return]  ${url}


Пошук цінової пропозиції
  [Arguments]  ${username}  ${tender_uaid}
  Switch browser   ${username}
  Click Element  xpath=//*[text()='Особистий кабiнет']
  Wait Until Element Is Visible    xpath=//*[@id='wrapper']/div[1]/span/b
  Click Element    xpath=//*[@id='wrapper']/div[1]/span/b
  Wait Until Element Is Visible    xpath=//*[@id='wrapper']//li[5]
  Sleep  3
  Click Element At Coordinates    xpath=//*[@id='wrapper']//li[5]/a    -15    0
  Wait Until Element Is Visible    xpath=//*[contains(text(), '${tender_uaid}')]//ancestor::tbody/tr[1]/td[1]/div
  Click Element    xpath=//*[contains(text(), '${tender_uaid}')]//ancestor::tbody/tr[1]/td[1]/div
  Wait Until Element Is Visible    xpath=//span[text()='Відкрити детальну інформацію']
  Click Element    xpath=//span[text()='Відкрити детальну інформацію']
  Sleep  20


Отримати посилання на аукціон для глядача
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}=${Empty}
  Sleep  230
  Selenium2Library.Switch Browser    ${username}
  upetem.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  :FOR    ${INDEX}    IN RANGE    1    11
  \  ${visible}  Run Keyword And Return Status  Element Should Be Visible  xpath=//div[@id='mForm:lotData1']/button
  \  Exit For Loop If  ${visible}
  \  Sleep  10
  \  Reload Page
  ${auction_url}=    Get Element Attribute    xpath=//*[contains(@onclick, 'https://auction-sandbox.openprocurement.org/tenders/')]@onclick
  ${url}=    Get Substring    ${auction_url}    13    97
  [return]  ${url}


#                      QUALIFICATION OPERATIONS                     #

Завантажити документ рішення кваліфікаційної комісії
  [Arguments]  ${username}  ${document}  ${tender_uaid}  ${award_num}
  upetem.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  :FOR    ${INDEX}    IN RANGE    1    11
  \  ${visible}  Run Keyword And Return Status  Element Should Be Visible  jquery=span:contains('Результати аукціону')
  \  Exit For Loop If  ${visible}
  \  Sleep  10
  \  Reload Page
  Execute Javascript  window.scrollTo(0,1100)
  Click Element  jquery=span:contains('Результати аукціону')
  Sleep  5
  Click Element  jquery=span:contains('Учасники аукціону')
  Sleep  5
  Click Element  jquery=span:contains('Оцінити')
  Sleep  5
  Choose File  id=mForm:tdFile_input  ${document}
  Sleep  5
  Click Element  id=mForm:docCard:dcType_label
  Click Element  id=mForm:docCard:dcType_1
  Click Element  jquery=span:contains('Зберегти'):last
  Sleep  5
  Click Element  jquery=span:contains('Зберегти'):first
  Sleep  10


Підтвердити постачальника
  [Arguments]  ${username}  ${tender_uaid}  ${award_num}
  Click Element  jquery=span:contains('Присвоїти звання переможця аукціону')
  Click Element  jquery=span:contains('Так'):last
  Sleep  5
  Click Element  jquery=span:contains('Зберегти оцінку')
  Sleep  10


Дискваліфікувати постачальника
  [Arguments]  ${username}  ${tender_uaid}  ${award_num}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Скасування рішення кваліфікаційної комісії
  [Arguments]  ${username}  ${tender_uaid}  ${award_num}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


#                       LIMITED PROCUREMENT                          #

Створити постачальника, додати документацію і підтвердити його
  [Arguments]  ${username}  ${tender_uaid}  ${supplier_data}  ${document}
  Switch browser  ${username}
  upetem.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element  jquery=span:contains('Оголосити')
  Click Element  xpath=//div[contains(@class, "ui-confirm-dialog") and @aria-hidden="false"]//span[text()="Оголосити"]
  Wait Until Keyword Succeeds  3x  1  Wait Until Element Is Visible  xpath=//span[contains(@class, "ui-button-text ui-c") and text()="Так"]
  Click Element                       xpath=//span[contains(@class, "ui-button-text ui-c") and text()="Так"]
  :FOR    ${INDEX}    IN RANGE    1    10
  \  Sleep  10
  \  Reload Page
  \  ${bid_status}=  Get Text  xpath=//*[@id="mForm:status"]
  \  Exit For Loop If  '${bid_status}' == 'Активна'
  ${s}  Set Variable  ${supplier_data.data}
  Click Element  jquery=span:contains('Учасники закупівлі')
  Click Element  jquery=span:contains('Новий учасник')
  Click Element  id=mForm:tabs:cLot_label
  Wait Until Element Is Visible  id=mForm:tabs:cLot_1
  Click Element  id=mForm:tabs:cLot_1
  Input Text  id=mForm:tabs:amount  ${s.value.amount}
  Execute Javascript  window.scrollTo(0,600)
  Click Element  xpath=(//table[@id='mForm:tabs:limited_qualification']//span)[1]
  Sleep  1
  Choose File  id=mForm:tabs:tFile_input  ${document}
  Wait Until Element Is Visible  xpath=(//div[@id='mForm:docCard:docCard']//button)[1]
  Click Element  xpath=(//div[@id='mForm:docCard:docCard']//button)[1]
  Wait Until Element Is Visible  id=mForm:tabs:pnlFilesT
  Input Text  id=mForm:tabs:rName  ${s.suppliers[0].contactPoint.name}
  Input Text  id=mForm:tabs:rMail  ${s.suppliers[0].contactPoint.email}
  ${s.suppliers[0].contactPoint.telephone}  Get Substring  ${s.suppliers[0].contactPoint.telephone}  0  13
  Input Text  id=mForm:tabs:rPhone  ${s.suppliers[0].contactPoint.telephone}
  Input Text  id=mForm:tabs:orgTin_input  ${s.suppliers[0].identifier.id}
  Click Element  xpath=(//table[@id='mForm:tabs:orgIsGos']//span)[1]
  ${s.suppliers[0].name}  Get Substring  ${s.suppliers[0].name}  0  50  # line limit
  Input Text  id=mForm:tabs:orgName  ${s.suppliers[0].name}
  Input Text  id=mForm:tabs:orgNameFull  ${s.suppliers[0].identifier.legalName}
  Input Text  id=mForm:tabs:zipCode  ${s.suppliers[0].address.postalCode}
  ${s.suppliers[0].address.region}  upetem_service.get_delivery_region  ${s.suppliers[0].address.region}
  Input Text  id=mForm:tabs:orgCReg_input  ${s.suppliers[0].address.region}
  Wait Until Element Is Visible  id=mForm:tabs:orgCReg_panel
  Click Element  xpath=(//div[@id='mForm:tabs:orgCReg_panel']//tr)[1]
  ${s.suppliers[0].address.locality}  upetem_service.convert_locality  ${s.suppliers[0].address.locality}
  Input Text  id=mForm:tabs:orgCTer_input  ${s.suppliers[0].address.locality}
  Wait Until Element Is Visible  id=mForm:tabs:orgCTer_panel
  Click Element  xpath=(//div[@id='mForm:tabs:orgCTer_panel']//tr)[1]
  Input Text  id=mForm:tabs:orgAddr  ${s.suppliers[0].address.streetAddress}
  Click Element  jquery=span:contains('Зберегти')
  Wait Until Element Is Visible  id=notifyMess
  Element Should Contain  id=notifyMess  Збережено!
  Wait Until Element Is Not Visible  id=notifyMess
  Wait Until Element Is Visible  jquery=span:contains('Так'):nth(1)
  Click Element  jquery=span:contains('Так'):nth(1)
  Wait Until Element Is Visible  jquery=span:contains('Зареєструвати пропозицію')
  Click Element  jquery=span:contains('Зареєструвати пропозицію')
  Wait Until Element Is Visible  id=notifyMess
  Element Should Contain  id=notifyMess  Ваша пропозиція реєструється
  :FOR    ${INDEX}    IN RANGE    1    11
  \  ${bid_status}  Get Text  xpath=(//tbody/tr[4]/td[2])[1]
  \  Exit For Loop If  '${bid_status}' == 'Зареєстрована'
  \  Sleep  20
  \  Reload Page
  Click Element  jquery=span:contains('Оголосити переможцем')
  Wait Until Element Is Visible  jquery=span:contains('Так'):nth(6)
  Click Element  jquery=span:contains('Так'):nth(6)
  :FOR    ${INDEX}    IN RANGE    1    11
  \  Sleep  20
  \  Reload Page
  \  ${win}  Run Keyword And Return Status  Element Should Contain  xpath=(//tbody/tr[4]/td[2])[1]  Закупівлю виграв учасник
  \  Exit For Loop If  ${win}
  ${TENDER_UAID}  Get Text  id=mForm:tabs:nBid
  Set To Dictionary  ${TENDER}  TENDER_UAID=${TENDER_UAID}


Скасувати закупівлю
  [Arguments]  ${username}  ${tender_uaid}  ${cancellation_reason}  ${document}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Завантажити документацію до запиту на скасування
  [Arguments]  ${username}  ${tender_uaid}  ${cancellation_reason}  ${document}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Змінити опис документа в скасуванні
  [Arguments]  ${username}  ${tender_uaid}  ${cancellation_id}  ${document_id}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Підтвердити скасування закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${cancell_id}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Отримати інформацію із документа до скасування
  [Arguments]  ${username}  ${tender_uaid}  ${cancellation_id}  ${doc_id}  ${field_name}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Отримати документ до скасування
  [Arguments]  ${username}  ${cancellation_id}  ${tender_uaid}  ${doc_id}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Підтвердити підписання контракту
  [Arguments]  ${username}  ${tender_uaid}  ${contract_num}
  Reload Page
  Click Element  jquery=span:contains('Підписати')
  Click Element  jquery=span:contains('Так'):nth(1)
  Wait Until Element Is Visible  xpath=//*[@id='j_idt12:PKeyFileName']
  Choose File  id=PKeyFileInput  ${CURDIR}/Key-6.dat
  Input Text  id=j_idt12:PKeyPassword  12345677
  Click Element  id=CAsServersSelect
  Sleep  3
  Click Element  jquery=option:contains('Тестовий ЦСК')
  Click Button  id=j_idt12:PKeyReadButton
  Wait Until Element Contains  id=PKStatusInfo  Ключ успішно завантажено
  Click Button  id=j_idt12:SignDataButton
  Sleep  10
  ${file_input}  Set Variable If  '${MODE}'=='belowThreshold'  mForm:j_idt406_input  mForm:pAcc:j_idt259_input
  Choose File  id=${file_input}  ${CURDIR}/LICENSE.txt
  Wait Until Element Is Visible  id=mForm:docCard:dcType_label
  Click Element  id=mForm:docCard:dcType_label
  Click Element  id=mForm:docCard:dcType_2
  ${save_button}  Set Variable If  '${MODE}'=='belowThreshold'  mForm:docCard:j_idt144  mForm:docCard:j_idt143
  Click Element  id=${save_button}
  Sleep  60  # обязательно нужно подождать минуту
  ${dc_input}  Evaluate  datetime.datetime.now().strftime("%d.%m.%Y %H:%M")  datetime
  ${x}  Set Variable If  '${MODE}'=='belowThreshold'  ${EMPTY}  pAcc:
  Input Text  id=mForm:${x}contractNumber  ${contract_num}
  Click Element  id=mForm:${x}periodStartDate_input
  Click Element  css=.ui-datepicker-today
  Sleep  3
  Click Element  id=mForm:${x}periodEndDate_input
  Click Element  css=.ui-datepicker-today
  Sleep  3
  Input Text     id=mForm:${x}dc_input  ${dc_input}
  Sleep  1
  Execute JavaScript  window.scrollTo(0,0)
  Sleep  1
  Click Button   id=mForm:bS
  Sleep  10
  Run Keyword If  '${MODE}'=='belowThreshold'  Click Element  jquery=span:contains('Завершити закупівлю')
  Run Keyword If  '${MODE}'=='belowThreshold'  Click Element  jquery=span:contains('Так'):last
  Run Keyword If  '${MODE}'!='belowThreshold'  Click Element  id=mForm:bS2
  Run Keyword If  '${MODE}'!='belowThreshold'  Click Element  xpath=(//*[@id='mForm:j_idt314'])[2]  # Так
  Sleep  5
  ${status_id}  Set Variable If  '${MODE}'=='belowThreshold'  mForm:cs  mForm:pAcc:contract_status_label
  ${expected_status}  Set Variable If  '${MODE}'=='belowThreshold'  Договір підписано  цей договір підписаний всіма учасниками, і зараз діє на законних підставах
  :FOR    ${INDEX}    IN RANGE    1    11
  \  ${contract_status}  Get Text  id=${status_id}
  \  Exit For Loop If  '${contract_status}' == '${expected_status}'
  \  Sleep  15
  \  Reload Page


#                               OPEN PROCUREMENT                                #

Підтвердити кваліфікацію
  [Arguments]  ${username}  ${tender_uaid}  ${qualification_num}
  upetem.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element  jquery=span:contains('Кваліфікація учасників')
  Click Element  jquery=span:contains('Відповідає кваліфікаційним критеріям'):nth(${qualification_num})
  Click Element  jquery=span:contains('Відсутні підстави для відмови в участі'):nth(${qualification_num})
  Click Element  jquery=span:contains('Допустити до аукціону'):nth(${qualification_num})
  Sleep  10


Відхилити кваліфікацію
  [Arguments]  ${username}  ${tender_uaid}  ${qualification_num}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Завантажити документ у кваліфікацію
  [Arguments]  ${username}  ${document}  ${tender_uaid}  ${qualification_num}
  upetem.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element  jquery=span:contains('Кваліфікація учасників')
  Wait Until Page Contains Element  jquery=span:contains('Завантажити рішення')
  Choose File  jquery=.ui-fileupload-choose:nth(${qualification_num}) input  ${document}
  Wait Until Element Is Visible  id=mForm:docCard:docCard
  Click Element  id=mForm:docCard:dcType_label
  Click Element  id=mForm:docCard:dcType_1
  Click Element  xpath=(//div[@id='mForm:docCard:docCard']//tfoot//button)[1]
  Sleep  5
  Click Element  jquery=span:contains('Зберегти'):nth(${qualification_num})
  Sleep  10


Скасувати кваліфікацію
  [Arguments]  ${username}  ${tender_uaid}  ${qualification_num}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Затвердити остаточне рішення кваліфікації
  [Arguments]  ${username}  ${tender_uaid}
  upetem.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element  jquery=span:contains('Кваліфікація учасників')
  Click Element  jquery=span:contains('Завершити оцінку пропозиції'):nth(0)
  Click Element  jquery=.ui-dialog-footer span:contains('Так'):nth(1)
  Sleep  5
  Click Element  jquery=span:contains('Завершити оцінку пропозиції'):nth(0)
  Click Element  jquery=.ui-dialog-footer span:contains('Так'):nth(2)
  Sleep  5
  Click Element  jquery=span:contains('Сформувати протокол розгляду пропозицій')
  Click Element  jquery=.ui-dialog-footer button:nth(5)
  Sleep  10


Перевести тендер на статус очікування обробки мостом
  [Arguments]  ${username}  ${tender_uaid}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Отримати доступ до тендера другого етапу
  [Arguments]  ${username}  ${tender_uaid}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Активувати другий етапу
  [Arguments]  ${username}  ${tender_uaid}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}
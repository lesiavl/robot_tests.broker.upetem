*** Settings ***

Library  String
Library  DateTime
Library  upetem_service.py
Library  get_xpath.py
Resource  subkeywords.robot
Resource  view.robot

*** Variables ***

${mail}          test_test@test.com
${telephone}     +380630000000
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
  Wait Until Page Contains Element    xpath=//*[text()='Вхід']   30
  Click Element                      xpath=//*[text()='Вхід']
  #Run Keyword If    '${username}' == 'upetem_Owner'    Click Element    id=mForm:j_idt118
  Wait Until Page Contains Element   id=mForm:email   20
  Input text   id=mForm:email      ${USERS.users['${username}'].login}
  Input text   id=mForm:pwd      ${USERS.users['${username}'].password}
  Click Button   id=mForm:login
  ${status}=   Run Keyword And Return Status   Page Should Contain Element   id=mForm:j_idt121
  Run Keyword if   '${status}' == 'True'
  ...  Run Keywords
  ...    Wait Until Element Is Visible  id=mForm:j_idt123  30
  ...    AND  Click Element  id=mForm:j_idt123


#                                    TENDER OPERATIONS                                           #

Створити тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_data
  #${file_path}=        local_path_to_file   TestDocument.docx
  ${prepared_tender_data}=   Get From Dictionary    ${ARGUMENTS[1]}                       data
  ${items}=                  Get From Dictionary    ${prepared_tender_data}               items
  ${lots}                    Get From Dictionary   ${prepared_tender_data}                   lots
  ${lot_title}               Get From Dictionary   ${lots[0]}                             title
  ${lot_desc}                Get From Dictionary   ${lots[0]}                             description
  ${lot_value_amount}        Get From Dictionary   ${lots[0].value}                       amount
  ${lot_step_rate}           Get From Dictionary   ${lots[0].minimalStep}                 amount
  # line below not needed for single item tender
  ${features}=  Run Keyword If  '${mode}'=='openua'  Get From Dictionary  ${prepared_tender_data}  features
  ${title}=                  Get From Dictionary    ${prepared_tender_data}               title
  ${title_en}=               Get From Dictionary    ${prepared_tender_data}               title_en
  ${description}=            Get From Dictionary    ${prepared_tender_data}               description
  ${description_en}=         Get From Dictionary    ${prepared_tender_data}               description_en

  ${budget}=                 Get From Dictionary    ${prepared_tender_data.value}         amount
  ${budget}=                 upetem_service.convert_float_to_string                    ${budget}
  ${step_rate}=              Get From Dictionary    ${prepared_tender_data.minimalStep}   amount
  ${step_rate}=              upetem_service.convert_float_to_string                    ${step_rate}
  # line below not needed for open ua
  ${enquiry_period_end_date}=  Run Keyword If  '${mode}'=='belowThreshold'  upetem_service.convert_date_to_string  ${prepared_tender_data.enquiryPeriod.endDate}
  ${tender_period}=          Get From Dictionary   ${prepared_tender_data}                tenderPeriod
  ${tender_period_start_date}=  upetem_service.convert_date_to_string  ${tender_period.startDate}
  ${tender_period_end_date}=  upetem_service.convert_date_to_string  ${tender_period.endDate}
  ${countryName}=   Get From Dictionary   ${prepared_tender_data.procuringEntity.address}       countryName
  ${item_description}=    Get From Dictionary    ${items[0]}    description
  ${item_description_en}=    Get From Dictionary    ${items[0]}    description_en
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
  #${dkpp_desc}=     Get From Dictionary   ${items[0].additionalClassifications[0]}   description
  #${dkpp_id}=       Get From Dictionary   ${items[0].additionalClassifications[0]}  id
  ${code}=           Get From Dictionary   ${items[0].unit}          code
  ${quantity}=      Get From Dictionary   ${items[0]}                        quantity
  ${name}=      Get From Dictionary   ${prepared_tender_data.procuringEntity.contactPoint}       name
  #${name_en}=    Get From Dictionary    ${prepared_tender_data.procuringEntity.contactPoint}     name_en
  #${procurement_type}=      Get From Dictionary   ${prepared_tender_data}   procurementMethodType
  Selenium2Library.Switch Browser     ${ARGUMENTS[0]}
  Wait Until Element Is Visible       xpath=//a[text()='Закупівлі']   10
  Click Element                       xpath=//a[text()='Закупівлі']
  Wait Until Page Contains Element    xpath=//*[text()='НОВА ЗАКУПІВЛЯ']   10
  Click Element                       xpath=//*[text()='НОВА ЗАКУПІВЛЯ']
  Wait Until Element Is Visible       xpath=//*[@id='mForm:procurementType_label']  10
  Click Element                       xpath=//*[@id='mForm:procurementType_label']
  Sleep  2
  ${procurement_type_xpath}=          get_xpath.get_procurement_type_xpath    ${mode}
  Click Element                       xpath=${procurement_type_xpath}
  #Run Keyword If  '${mode}' == 'belowThreshold'  Click Element  //*[@id='mForm:procurementType_0']
  Sleep  2
  Click Element                       xpath=//*[@id="mForm:chooseProcurementTypeBtn"]
  ###Wait Until Element Is Visible       xpath=//*[@id='mForm:j_idt96:j_idt99']  30
  ###Click Element                       xpath=//*[@id='mForm:j_idt96:j_idt99']
  Wait Until Page Contains Element    id=mForm:name  10
  Input text                          id=mForm:name     ${title}
  Input text                          id=mForm:desc     ${description}
  Click Element                       id=mForm:cKind_label
  Sleep  2
  Click Element                       xpath=//div[@id='mForm:cKind_panel']//li[3]
  ${budget_selector}=  Set Variable If  ${NUMBER_OF_LOTS}==0  mForm:budget  mForm:lotBudg0
  Input text                          id=${budget_selector}   ${budget}
  Input text                          id=mForm:lotTitle0  ${lot_title}
  Input text                          id=mForm:lotDesc0   ${lot_desc}
# Input text                          id=mForm:lotStep0   ${lot_step_rate}
  ${vat_selector}=  Set Variable If  ${NUMBER_OF_LOTS}==0  mForm:vat  mForm:lotVat0
  Click Element                       xpath=//*[@id='${vat_selector}']/tbody/tr/td[1]//div[2]
#  Press Key                           id=mForm:lotStepPercent0   \\49  # workaround to properly input "1"
  ${step_selector}=  Set Variable If  ${NUMBER_OF_LOTS}==0  mForm:step  mForm:lotStep0
  Sleep  12
  Click Element  id=${step_selector}
  Sleep  3
  Input text  id=${step_selector}  ${step_rate}
  # two lines below not needed for open ua
  Run Keyword If  '${mode}'=='belowThreshold'  Input text  xpath=//*[@id="mForm:dEA_input"]  ${enquiry_period_end_date}
  Run Keyword If  '${mode}'=='belowThreshold'  Input text  xpath=//*[@id="mForm:dSPr_input"]  ${tender_period_start_date}
  Input text                          xpath=//*[@id="mForm:dEPr_input"]  ${tender_period_end_date}
  Input text                          id=mForm:cCpvGrL_input      ${cpv_id_1}
  Wait Until Element Is Visible       xpath=.//*[@id='mForm:cCpvGrL_panel']/table/tbody/tr/td[2]/span   90
  Click Element                       xpath=.//*[@id='mForm:cCpvGrL_panel']/table/tbody/tr/td[2]/span

  Run Keyword If  '${mode}' == 'openua'  upetem.Додати неціновий показник на тендер  ${features}

  Input text                          id=mForm:lotItems0:lotItem_0:cCpv_input   ${cpv_id}
  Wait Until Element Is Visible       xpath=//div[@id='mForm:lotItems0:lotItem_0:cCpv_panel']//td[1]/span   90
  Click Element                       xpath=//div[@id='mForm:lotItems0:lotItem_0:cCpv_panel']//td[1]/span
  Input text                          id=mForm:lotItems0:lotItem_0:cDkpp_input    ${dkpp_id}
#  Wait Until Element Is Visible       xpath=//div[@id='mForm:lotItems0:lotItem_0:cDkpp_panel']//tr[1]/td[2]/span   90
#  Click Element                       xpath=//div[@id='mForm:lotItems0:lotItem_0:cDkpp_panel']//tr[1]/td[2]/span
  Sleep  2
  Input text                          id=mForm:lotItems0:lotItem_0:subject    ${item_description}
  Sleep  2
  Input text                          id=mForm:lotItems0:lotItem_0:unit_input    ${code}
  Wait Until Element Is Visible       xpath=//div[@id='mForm:lotItems0:lotItem_0:unit_panel']//tr/td[1]   90
  Click Element                       xpath=//div[@id='mForm:lotItems0:lotItem_0:unit_panel']//tr/td[1]
  Input text                          id=mForm:lotItems0:lotItem_0:amount   ${quantity}
  Input Text                          xpath=//*[@id='mForm:lotItems0:lotItem_0:delDS_input']  ${delivery_start_date}
  Input text                          xpath=//*[@id="mForm:lotItems0:lotItem_0:delDE_input"]  ${delivery_end_date}
  Click Element                       xpath=//*[@id="mForm:lotItems0:lotItem_0:cReg"]/div[3]
  Sleep  2
  Click Element                       xpath=//ul[@id='mForm:lotItems0:lotItem_0:cReg_items']/li[text()='${item_delivery_region}']
  Sleep  2
  Input Text                          xpath=//*[@id="mForm:lotItems0:lotItem_0:cTer_input"]    ${item_locality}
  Wait Until Element Is Visible       xpath=//*[@id='mForm:lotItems0:lotItem_0:cTer']//td[1]    60
  Press Key                           //*[@id="mForm:lotItems0:lotItem_0:cTer_input"]    \\13
  Input text                          id=mForm:lotItems0:lotItem_0:zc  ${item_delivery_postal_code}
  Input text                          xpath=//*[@id="mForm:lotItems0:lotItem_0:delAdr"]  ${item_delivery_address_street_address}
  Input text                          id=mForm:lotItems0:lotItem_0:delLoc1  ${latitude}
  Input text                          id=mForm:lotItems0:lotItem_0:delLoc2  ${longitude}
  #Execute Javascript    $('#mForm:lotItems0:delLoc1').val('${latitude}')
  #Execute Javascript    $('#mForm:lotItems0:delLoc2').val('${longitude}')

  Run Keyword If  '${mode}' == 'openua'  upetem.Додати неціновий показник на лот  ${features}
  Run Keyword If  '${mode}' == 'openua'  upetem.Додати неціновий показник на предмет  ${EMPTY}  ${EMPTY}  ${features}  ${EMPTY}

  Input text                          id=mForm:rName     ${name}
  Input text                          id=mForm:rPhone    ${telephone}
  Input text                          id=mForm:rMail     ${mail}
  #  Input text                          id=mForm:data:stepPercent  1
  #  Завантажити документ до тендеру  ${file_path}
  Sleep  2
  Run Keyword if   '${mode}' == 'multi'   Додати предмет   items
  # Save
  Click Element                       xpath=//*[@id="mForm:bSave"]
  Wait Until Element Is Visible       xpath=//div[contains(@class, "ui-confirm-dialog") and @aria-hidden="false"]//span[text()='Так']    60
  Click Element                       xpath=//div[contains(@class, "ui-confirm-dialog") and @aria-hidden="false"]//span[text()='Так']
  #Add language
  #Run Keyword If  '${procurement_type}' == 'aboveThresholdEU'  subkeywords.Додати мову закупівлі  ${title_en}  ${description_en}  ${name_en}  ${items}  ${lots}  ${features}
  # Announce
  Execute JavaScript                  window.scrollTo(0, 0)
  Wait Until Keyword Succeeds  3x  1  Wait Until Element Is Visible  xpath=//span[text()="Оголосити"]  60
  Click Element                       xpath=//span[text()="Оголосити"]
  # Confirm in message box
  Click Element                       xpath=//div[contains(@class, "ui-confirm-dialog") and @aria-hidden="false"]//span[text()="Оголосити"]
  Wait Until Keyword Succeeds  3x  1  Wait Until Element Is Visible       xpath=//span[contains(@class, "ui-button-text ui-c") and text()="Так"]
  Click Element                       xpath=//span[contains(@class, "ui-button-text ui-c") and text()="Так"]

  :FOR    ${INDEX}    IN RANGE    1    10
  \  ${bid_status}=  Get Text  xpath=//*[@id="mForm:status"]
  \  Exit For Loop If  '${bid_status}' == 'Очікування пропозицій'
  \  Sleep  10
  \  Reload Page

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
  ${current_location}=   Get Location
  Wait Until Element Is Visible    xpath=//a[./text()="Закупівлі"]    60
  Click Element                    xpath=//a[./text()="Закупівлі"]
  Wait Until Element Is Visible    xpath=//div[@id='buttons']/button[1]    30
  Click Element                    xpath=//div[@id='buttons']/button[1]
  Input Text                       xpath=//*[@id='search-by-number']/input    ${ARGUMENTS[1]}
  Click Element                    id=mForm:search_button
  Wait Until Page Contains Element  xpath=//a[text()='${ARGUMENTS[1]}']/ancestor::div[1]/span[2]/a
  Click Element    xpath=//a[text()='${ARGUMENTS[1]}']/ancestor::div[1]/span[2]/a
  Wait Until Page Contains Element  id=mForm:nBid
  Element Should Contain  id=mForm:nBid  ${ARGUMENTS[1]}


Оновити сторінку з тендером
  [Arguments]  ${username}  ${tender_uaid}
  Selenium2Library.Switch Browser    ${username}
  upetem.Пошук тендера по ідентифікатору    ${username}   ${tender_uaid}
  Reload Page


Отримати інформацію із тендера
  [Arguments]  ${username}  ${tender_uaid}  ${fieldname}
  Selenium2Library.Switch browser   ${username}
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
  Wait Until Element Is Visible    xpath=//*[text()='Картка документу']    30
  Click Element                    xpath=//*[@id="mForm:docCard:dcType_label"]
  Wait Until Element Is Visible    xpath=//*[@id="mForm:docCard:dcType_panel"]    30
  Click Element                    xpath=//*[@id="mForm:docCard:dcType_panel"]/div/ul/li[2]
  Sleep  2
  Click Element                    xpath=//*[@id="mForm:docCard:docCard"]/table/tfoot/tr/td/button[1]
  Sleep  20
  Input text                       id=mForm:docAdjust     Test text
  Sleep  5
  Click Element                    xpath=//*[@id="mForm:bSave"]
  Wait Until Element Is Visible    xpath=(//*[@id="primefacesmessagedlg"]/div/a)[1]    120
  Click Element                    xpath=(//*[@id="primefacesmessagedlg"]/div/a)[1]
  Sleep  5


Set Multi Ids
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${tender_UAid}
  ${id}=           Get Text           id=mForm:nBid
  ${Ids}   Create List    ${tender_UAid}   ${id}


Отримати інформацію із документа
  [Arguments]  ${username}  ${tender_uaid}  ${doc_id}  ${field}
  #Sleep  250
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
  [Arguments]  ${username}  ${tender_uaid}  ${item}
  Fail    "Драйвер не реалізовано"
  Switch browser    ${username}


Отримати інформацію із предмету
  [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${field_name}
  Switch browser    ${username}
  #Run Keyword If    '${TEST_NAME}' == 'Відображення опису номенклатури у новому лоті'    Sleep  45
  Run Keyword If    '${TEST_NAME}' == 'Відображення опису номенклатури у новому лоті'    subkeywords.Switch new lot    ${username}  ${tender_uaid}
  Run Keyword If    '${TEST_NAME}' == 'Відображення опису нової номенклатури'    upetem.Пошук тендера по ідентифікатору    ${username}  ${tender_uaid}
  Run Keyword If    '${TEST_NAME}' == 'Відображення опису нової номенклатури'    Wait Until Keyword Succeeds  300 s  30s  subkeywords.Wait For NewItem    ${item_id}
  #${status}=    Run Keyword And Return Status    Page Should Contain Element    xpath=//*[contains(text(), '${item_id}')]
  #Run Keyword if    '${status}' == 'False'    Click Element    xpath=//*[@id='lotTabButton_2']
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
  Input Text  id=mForm:lotBudg0  "${fieldvalue}"
  Sleep  12
  Wait Until Keyword Succeeds  3x  1  Click Element  id=mForm:lotStep0
  Sleep  2
  Wait Until Keyword Succeeds  3x  1  Input Text  id=mForm:lotStep0  "${fieldvalue//100}"
  Sleep  2
  Click Button  id=mForm:bSave
  Sleep  2
  Element Should Not Be Visible  css=.ui-message-error-detail
  Wait Until Element Is Visible  id=notifyMess  30
  Element Should Contain  id=notifyMess  Збережено!


Додати предмет закупівлі в лот
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${item}
  Fail    "Драйвер не реалізовано"
  Switch browser    ${username}


Завантажити документ в лот
    [Arguments]    ${username}    ${filepath}    ${TENDER_UAID}    ${lot_id}
    upetem.Пошук тендера по ідентифікатору    ${username}    ${TENDER_UAID}
    Log  ${filepath}
    Log  ${lot_id}
    Choose File       xpath=//*[@id='mForm:docFile_input']    ${filepath}
    Wait Until Element Is Visible    xpath=//*[text()='Картка документу']    30
    Click Element                    xpath=//*[@id="mForm:docCard:dcType_label"]
    Wait Until Element Is Visible    xpath=//*[@id="mForm:docCard:dcType_panel"]    30
    Click Element                    xpath=//*[@id="mForm:docCard:dcType_panel"]/div/ul/li[2]
    Sleep  2
    Input Text  xpath=//div[@id="mForm:docCard:docCard"]//tr[5]//textarea  Тестовий опис
    Click Element  xpath=//div[@id="mForm:docCard:docCard"]/table//tr[7]//td[2]//label
    Wait Until Element Is Visible  xpath=//div[@id="mForm:docCard:docCard"]//tr[7]//td[2]//ul
    Click Element  xpath=//div[@id="mForm:docCard:docCard"]//tr[7]//td[2]//li[contains(.,"${lot_id}")]
    Sleep  2
    Click Element                    xpath=//*[@id="mForm:docCard:docCard"]/table/tfoot/tr/td/button[1]
    Sleep  20
    Input text                       id=mForm:docAdjust     Додано тестовий документ для лоту
    Sleep  5
    Click Element                    xpath=//*[@id="mForm:bSave"]
    Wait Until Element Is Visible    xpath=(//*[@id="primefacesmessagedlg"]/div/a)[1]  30
    Click Element                    xpath=(//*[@id="primefacesmessagedlg"]/div/a)[1]
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
  Sleep  3
  Execute Javascript  document.getElementById("mForm:meatpanel").scrollIntoView(false)
  Input Text  xpath=//*[@id='mForm:meatpanel']//input  ${features[1].title}
  Input Text  xpath=//*[@id='mForm:meatpanel']//textarea  ${features[1].description}
  ${i}  Set Variable  ${0}
  :FOR    ${index}  ${element}    IN ENUMERATE  @{features[1].enum}
  \  Run Keyword If  ${index} > 0  Click Element  css=.ui-datatable-header.ui-widget-header.ui-corner-top button
  \  Run Keyword If  ${index} > 0  Wait Until Page Contains Element  jquery=.ui-datatable-tablewrapper td:nth(${i})
  \  Click Element  jquery=.ui-datatable-tablewrapper td:nth(${i})
  \  Input Text     jquery=.ui-datatable-tablewrapper td:nth(${i}) input  ${element.title}
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
  Execute Javascript  window.scrollTo(0,3300)
  Sleep  1
  Click Element  jquery=span:contains('Додати показник'):nth(1)
  Sleep  3
  Execute Javascript  document.getElementById("mForm:lotItems0:meatDataLot0").scrollIntoView(false)
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
  Run Keyword If  '${TEST_NAME}' == 'Можливість додати неціновий показник на перший предмет'  Wait Until Element Is Visible  id=notifyMess  30


Додати неціновий показник на лот
  [Arguments]  ${features}
  Click Element  jquery=span:contains('Додати показник'):nth(1)
  Sleep  3
  Execute Javascript  document.getElementById("mForm:lotItems0:meatDataLot0").scrollIntoView(false)
  Input Text  xpath=//div[@id='mForm:lotItems0:meatDataLot0']//input  ${features[0].title}
  Input Text  xpath=//div[@id='mForm:lotItems0:meatDataLot0']//textarea  ${features[0].description}
  ${i}  Set Variable  ${0}
  :FOR    ${index}  ${element}    IN ENUMERATE  @{features[0].enum}
  \  Run Keyword If  ${index} > 0  Click Element  jquery=.ui-datatable-header.ui-widget-header.ui-corner-top:nth(1) button
  \  Run Keyword If  ${index} > 0  Wait Until Page Contains Element  jquery=.ui-datatable-tablewrapper:nth(1) td:nth(${i})
  \  Click Element  jquery=.ui-datatable-tablewrapper:nth(1) td:nth(${i})
  \  Input Text     jquery=.ui-datatable-tablewrapper:nth(1) td:nth(${i}) input  ${element.title}
  \  Click Element  jquery=.ui-datatable-tablewrapper:nth(1) td:nth(${i+1})
  \  Input Text     jquery=.ui-datatable-tablewrapper:nth(1) td:nth(${i+1}) input  Тестовий коментар
  \  Click Element  jquery=.ui-datatable-tablewrapper:nth(1) td:nth(${i+2})
  \  ${value}  Evaluate  int(${element.value}*100)
  \  Press Key  css=div.ui-cell-editor-input[style='display: block;'] input  \\127  # necessary workaround
  \  Input Text     jquery=.ui-datatable-tablewrapper:nth(1) td:nth(${i+2}) input  ${value}
  \  ${i}  Set Variable  ${i+4}


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
  Wait Until Element Is Not Visible  xpath=//div[@id='mForm:lotItems0:meatDataLot0']/table[3]//td/button  20
  Click Element  id=mForm:bSave
  Wait Until Element Is Visible  id=notifyMess  30


#                                    QUESTION                                               #

Задати запитання на тендер
  [Arguments]  ${username}  ${tender_uaid}  ${question}

  ${title}=         Get From Dictionary   ${question.data}   title
  ${description}=   Get From Dictionary   ${question.data}   description

  Selenium2Library.Switch Browser    ${username}
  Sleep  5
  upetem.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
  Wait Until Element Is Visible       xpath=//span[./text()='Обговорення']    30
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
  Wait Until Element Is Visible       xpath=//span[./text()='Обговорення']    30
  Click Element                       xpath=//span[./text()='Обговорення']
  Wait Until Element Is Visible       xpath=//*[@id='mForm:questTo_label']    30
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
  Wait Until Element Is Visible        xpath=//span[./text()='Обговорення']   30
  Click Element                        xpath=//span[./text()='Обговорення']
  Wait Until Element Is Visible       xpath=//*[@id='mForm:questTo_label']    30
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
  Wait Until Element Is Visible    xpath=//*[@id="mForm:status"]   60
  ${tender_status}=    Get Text    xpath=//*[@id="mForm:status"]
#  Run Keyword If  '${tender_status}' != 'Період уточнень'    Fail    "Період уточнень закінчився"
  Click Element                      xpath=//span[./text()='Обговорення']
  Sleep  3
  Click Element                      xpath=//span[contains(text(), '${question_id}')]/ancestor::div[@id='mForm:data_content']//button
  Input Text    xpath=//*[@id="mForm:messT"]    "Test answer"
  Input Text    xpath=//*[@id="mForm:messQ"]    ${answer}
  Sleep  2
  Click Element                      xpath=//*[@id="mForm:btnR"]
  Wait Until Element Is Visible  id=notifyMess  30
  Element Should Contain  id=notifyMess  Збережено!

#                                CLAIMS                                 #

Створити чернетку вимоги про виправлення умов закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${claim}
  upetem.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
  #Wait Until Element Is Visible       xpath=//span[text()='Вимоги та скарги']    30
  #Click Element    xpath=//span[text()='Вимоги та скарги']
  Run Keyword If    '${mode}' != 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги та скарги']
  Run Keyword If    '${mode}' == 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги та звернення']
  Sleep  2
  Click Element    xpath=//span[text()='Нова вимога']
  Wait Until Element Is Visible    //span[text()='Обрати']    30
  Click Element    xpath=//span[text()='Обрати']
  Sleep  2
  Input Text    xpath=//*[@id='mForm:data:title']    ${claim.data.title}
  Sleep  2
  Input Text    xpath=//*[@id='mForm:data:description']    ${claim.data.description}
  Sleep  2
  Click Element    xpath=//span[text()='Зареєструвати']
  Sleep  30


Створити чернетку про виправлення умов лоту
  [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${lot_id}
  Fail    "Драйвер не реалізовано"
  Switch browser    ${username}


Створити чернетку вимоги про виправлення визначення переможця
  [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${award_index}
  Fail    "Драйвер не реалізовано"
  Switch browser    ${username}


Створити вимогу про виправлення умов закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${document}=${None}
  upetem.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
  Run Keyword If    '${mode}' != 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги та скарги']
  Run Keyword If    '${mode}' == 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги та звернення']
  #Wait Until Element Is Visible       xpath=//span[text()='Вимоги та скарги']    30
  #Click Element    xpath=//span[text()='Вимоги та скарги']
  Sleep  2
  Click Element    xpath=//span[text()='Нова вимога']
  Sleep  5
  #Wait Until Element Is Visible    xpath=//span[text()='Обрати']    30
  Run Keyword If    '${TEST_NAME}' != 'Можливість створити і подати вимогу про виправлення умов лоту'    Click Element    xpath=//span[text()='Обрати']
  Sleep  2
  Input Text    xpath=//*[@id='mForm:data:title']    ${claim.data.title}
  Sleep  2
  Input Text    xpath=//*[@id='mForm:data:description']    ${claim.data.description}
  Sleep  2
  Run Keyword If    '${document}' != '${None}'    Choose File    xpath=//*[text()='Завантажити документ']//ancestor::div[1]//input    ${document}

  Click Element    xpath=//span[text()='Зареєструвати']
  Sleep  30
  ${type}=  Set Variable If    'закупівлі' in '${TEST_NAME}'    tender
  ...                          'лоту' in '${TEST_NAME}'    lot
  ${complaintID}=    upetem_service.convert_complaintID    ${tender_uaid}    ${type}
  Sleep  90
  [return]  ${complaintID}


Створити вимогу про виправлення умов лоту
  [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${lot_id}  ${document}=${None}
  upetem.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
  Run Keyword If    '${mode}' != 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги та скарги']
  Run Keyword If    '${mode}' == 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги та звернення']
  #Wait Until Element Is Visible       xpath=//span[text()='Вимоги та скарги']    30
  #Click Element    xpath=//span[text()='Вимоги та скарги']
  Sleep  2
  Click Element    xpath=//span[text()='Нова вимога']
  Sleep  5
  Input Text    xpath=//*[@id='mForm:data:title']    ${claim.data.title}
  Sleep  2
  Input Text    xpath=//*[@id='mForm:data:description']    ${claim.data.description}
  Sleep  2
  Run Keyword If    '${document}' != '${None}'    Choose File    xpath=//*[text()='Завантажити документ']//ancestor::div[1]//input    ${document}

  Click Element    xpath=//span[text()='Зареєструвати']
  Sleep  30
  ${type}=  Set Variable If    'закупівлі' in '${TEST_NAME}'    tender
  ...                          'лоту' in '${TEST_NAME}'    lot
  ${complaintID}=    upetem_service.convert_complaintID    ${tender_uaid}    ${type}
  Sleep  90
  [return]  ${complaintID}


Створити вимогу про виправлення визначення переможця
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_uaid
  ...      ${ARGUMENTS[2]} ==  claim
  ...      ${ARGUMENTS[3]} ==  award_index
  ...      ${ARGUMENTS[4]} ==  document

  Fail    "Драйвер не реалізовано"
  Switch browser    ${ARGUMENTS[0]}


Завантажити документацію до вимоги
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${document}
  upetem.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
  Click Element    xpath=//span[text()='Вимоги та скарги']
  Wait Until Element Is Visible    xpath=//*[text()='${complaintID}']    30
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
  Fail    "Драйвер не реалізовано"
  Switch browser    ${username}


Відповісти на вимогу про виправлення умов лоту
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${answer_data}
  Fail    "Драйвер не реалізовано"
  Switch browser    ${username}


Відповісти на вимогу про виправлення визначення переможця
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${answer_data}  ${award_index}
  Fail    "Драйвер не реалізовано"
  Switch browser    ${username}


Підтвердити вирішення вимоги про виправлення умов закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${confirmation_data}
  upetem.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
  Run Keyword If    '${mode}' != 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги та скарги']
  Run Keyword If    '${mode}' == 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги та звернення']
  #Click Element    xpath=//span[text()='Вимоги та скарги']
  Sleep  2
  Click Element    xpath=(//*[@id='mForm:data_data']/tr/td[1]/a)[1]
  Sleep  2
  Click Element    xpath=//*[text()='Погодитись з відповіддю']
  Sleep  25


Підтвердити вирішення вимоги про виправлення умов лоту
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${confirmation_data}
  upetem.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
  Run Keyword If    '${mode}' != 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги та скарги']
  Run Keyword If    '${mode}' == 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги та звернення']
  #Click Element    xpath=//span[text()='Вимоги та скарги']
  Sleep  2
  Click Element    xpath=(//*[@id='mForm:data_data']/tr/td[1]/a)[1]
  Sleep  2
  Click Element    xpath=//*[text()='Погодитись з відповіддю']
  Sleep  25


Підтвердження вирішення вимоги про виправлення визначення переможця
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${confirmation_data}  ${award_index}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Скасувати вимогу про виправлення умов закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${cancellation_data}
  upetem.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
  Click Element    xpath=//span[text()='Вимоги та скарги']
  Wait Until Element Is Visible    xpath=//*[text()='${complaintID}']    30
  Click Element    //*[text()='${complaintID}']
  Input Text    xpath=//*[@id='mForm:data:cancellationReason']    ${cancellation_data.data.cancellationReason}
  Click Element    xpath=//*[text()='Відмінити вимогу/скаргу']


Скасувати вимогу про виправлення умов лоту
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${cancellation_data}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Скасувати вимогу про виправлення визначення переможця
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${cancellation_data}  ${award_index}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


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
  Run Keyword If    '${mode}' == 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги та звернення']
  #Click Element    xpath=//*[text()='Вимоги та скарги']
  #Wait Until Element Is Visible    xpath=//*[@id='mForm:data_data']/tr/td[1]/a    30
  Run Keyword If    "${TEST_NAME}" == "Відображення опису вимоги"    Wait Until Keyword Succeeds  300 s  10 s  subkeywords.Wait For ClaimTender
  Run Keyword If    "${TEST_NAME}" == "Відображення опису вимоги про виправлення умов закупівлі"    Wait Until Keyword Succeeds  300 s  10 s  subkeywords.Wait For ClaimTender
  Run Keyword If    "${TEST_NAME}" == "Відображення опису вимоги про виправлення умов лоту"    Wait Until Keyword Succeeds  300 s  10 s  subkeywords.Wait For ClaimLot
  Click Element    xpath=(//*[@id='mForm:data_data']/tr/td[1]/a)[1]
  Sleep  3
  Run Keyword If    "${TEST_NAME}" == "Можливість відповісти на вимогу про виправлення умов закупівлі"    Wait Until Keyword Succeeds  420 s  15 s  subkeywords.Wait For Answered
  Run Keyword If    "${TEST_NAME}" == "Можливість відповісти на вимогу про виправлення умов лоту"    Wait Until Keyword Succeeds  420 s  15 s  subkeywords.Wait For Answered
  Run Keyword If    "${TEST_NAME}" == "Відображення статусу 'answered' вимоги"    Wait Until Keyword Succeeds  300 s  15 s  subkeywords.Wait For Answered
  Run Keyword If    "${TEST_NAME}" == "Відображення статусу 'answered' вимоги про виправлення умов закупівлі"    Wait Until Keyword Succeeds  300 s  15 s  subkeywords.Wait For Answered
  Run Keyword If    "${TEST_NAME}" == "Відображення статусу 'answered' вимоги про виправлення умов лоту"    Wait Until Keyword Succeeds  300 s  15 s  subkeywords.Wait For Answered
  Run Keyword If    "${TEST_NAME}" == "Відображення задоволення вимоги"    Wait Until Keyword Succeeds  300 s  15 s  subkeywords.Wait For Satisfied
  Run Keyword If    "${TEST_NAME}" == "Відображення незадоволення вимоги"    Wait Until Keyword Succeeds  300 s  15 s  subkeywords.Wait For Satisfied
  Run Keyword If    "${TEST_NAME}" == "Відображення статусу 'resolved' вимоги про виправлення умов закупівлі"    Wait Until Keyword Succeeds  300 s  15 s  subkeywords.Wait For Satisfied
  Run Keyword If    "${TEST_NAME}" == "Відображення статусу 'resolved' вимоги про виправлення умов лоту"    Wait Until Keyword Succeeds  300 s  15 s  subkeywords.Wait For Satisfied
  Run Keyword If    "Відображення статусу 'cancelled'" in "${TEST_NAME}"    Wait Until Keyword Succeeds  300 s  15 s  subkeywords.Wait For Cancelled
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
  #Click Element    xpath=//*[text()='Вимоги та скарги']
  Run Keyword If    '${mode}' != 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги та скарги']
  Run Keyword If    '${mode}' == 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги та звернення']
  Wait Until Element Is Visible    xpath=//*[@id='mForm:data_data']/tr/td[1]/a    30
  Click Element    xpath=(//*[@id='mForm:data_data']/tr/td[1]/a)[1]
  Sleep  3
  ${value}=    Get Text    xpath=//*[contains(text(), '${doc_id}')]
  [return]  ${value}


Отримати документ до скарги
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${doc_id}  ${award_id}=${None}
  upetem.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  #Click Element    xpath=//*[text()='Вимоги та скарги']
  Run Keyword If    '${mode}' != 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги та скарги']
  Run Keyword If    '${mode}' == 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги та звернення']
  Wait Until Element Is Visible    xpath=//*[@id='mForm:data_data']/tr/td[1]/a    30
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
  Input Text  xpath=//*[@id="mForm:data:rPhone"]    ${telephone}
  Input Text  xpath=//*[@id="mForm:data:rMail"]    ${mail}

  Click Element  xpath=//*[text()='Зберегти']
  Sleep  3
  Wait Until Element Is Visible    xpath=//*[@id='mForm:proposalSaveInfo']/div[3]/button    60
  Click Element  xpath=//*[@id='mForm:proposalSaveInfo']/div[3]/button/span[2]
  Sleep  2
  Wait Until Element Is Visible    xpath=//*[text()='Зареєструвати пропозицію']    60
  Click Element  xpath=//*[text()='Зареєструвати пропозицію']
  Wait Until Element Is Visible    xpath=//*[@id='mForm:cdPay']    60
  Click Element    xpath=//*[@id='mForm:cdPay']/div[2]/table//tr[6]/td//tr[2]/td/div
#  Sleep  2
#  Click Element    xpath=(//li[contains(text(), "${USERS.users['${username}'].login}")])[2]
  Sleep  2
  Click Element  xpath=(//*[text()='Зареєструвати пропозицію'])[2]
  Wait Until Element Is Visible    //*[@id='mForm:data']/div[1]/table/tbody/tr[5]/td[2]    90
  ${bid_status}=    Get Text    xpath=//*[@id='mForm:data']/div[1]/table/tbody/tr[5]/td[2]
  :FOR    ${INDEX}    IN RANGE    1    25
  \  Exit For Loop If  '${bid_status}' == 'Зареєстрована'
  \  Sleep  3
  \  ${bid_status}=  Get Text  xpath=//*[@id='mForm:data']/div[1]/table/tbody/tr[5]/td[2]
  \  Run Keyword If  '${bid_status}' == 'Реєструється'  Sleep  25
  \  Run Keyword If  '${bid_status}' == 'Реєструється'  Reload Page
  Sleep  30


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
  Wait Until Element Is Visible    xpath=//*[@id='mForm:docCard:dcType_label']    60
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
  Wait Until Element Is Visible    xpath=//*[text()= 'Картка документу']
  Choose File       xpath=//*[@id='mForm:docCard:dcFile_input']    ${path}
  Sleep  5
  Click Element    xpath=//*[@id="mForm:docCard:docCard"]/table/tfoot/tr/td/button[1]
  Sleep  20
  Click Element    xpath=//*[text()='Зберегти']
  Sleep  25


Змінити документацію в ставці
  [Arguments]  ${username}  ${tender_uaid}  ${doc_data}  ${doc_id}
  upetem.Пошук цінової пропозиції  ${username}  ${tender_uaid}
  Execute JavaScript                  window.scrollTo(0, 800)
  Sleep  2
  Click Element    xpath=//a[contains(text(), '${doc_id}')]//ancestor::tr/td[6]/button[1]/span[1]
  Wait Until Element Is Visible    xpath=//*[text()= 'Картка документу']    30
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
  #Page Should Contain Element  xpath=//*[text()='Перегляд аукціону']
  #Wait Until Element Is Visible    xpath=//*[contains(text(), '${lot_id}')]//ancestor::div[2]/div[2]/button[1]
  Wait Until Element Is Visible    xpath=//*[contains(@onclick, 'https://auction-sandbox.openprocurement.org/tenders/')]    30
  Sleep  2
  #${url}=    Get Element Attribute    xpath=//*[contains(text(), '${lot_id}')]//ancestor::div[2]/div[2]/button[1]@href
  ${auction_url}=    Get Element Attribute    xpath=//*[contains(@onclick, 'https://auction-sandbox.openprocurement.org/tenders/')]@onclick
  ${url}=    Get Substring    ${auction_url}    13    97
  [return]  ${url}


Пошук цінової пропозиції
  [Arguments]  ${username}  ${tender_uaid}
  Switch browser   ${username}
  Click Element  xpath=//*[text()='Особистий кабiнет']
  Wait Until Element Is Visible    xpath=//*[@id='wrapper']/div[1]/span/b    30
  Click Element    xpath=//*[@id='wrapper']/div[1]/span/b
  Wait Until Element Is Visible    xpath=//*[@id='wrapper']//li[5]    30
  Sleep  3
  Click Element At Coordinates    xpath=//*[@id='wrapper']//li[5]/a    -15    0
  Wait Until Element Is Visible    xpath=//*[contains(text(), '${tender_uaid}')]//ancestor::tbody/tr[1]/td[1]/div    30
  Click Element    xpath=//*[contains(text(), '${tender_uaid}')]//ancestor::tbody/tr[1]/td[1]/div
  Wait Until Element Is Visible    xpath=//span[text()='Відкрити детальну інформацію']    30
  Click Element    xpath=//span[text()='Відкрити детальну інформацію']
  Sleep  20


Отримати посилання на аукціон для глядача
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}=${Empty}
  Sleep  230
  Selenium2Library.Switch Browser    ${username}
  upetem.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  #Page Should Contain Element  xpath=//*[text()='Перегляд аукціону']
  #Wait Until Element Is Visible    xpath=//*[contains(text(), '${lot_id}')]//ancestor::div[2]/div[2]/button[1]
  Wait Until Element Is Visible    xpath=//*[contains(@onclick, 'https://auction-sandbox.openprocurement.org/tenders/')]    30
  Sleep  2
  #${url}=    Get Element Attribute    xpath=//*[contains(text(), '${lot_id}')]//ancestor::div[2]/div[2]/button[1]@href
  ${auction_url}=    Get Element Attribute    xpath=//*[contains(@onclick, 'https://auction-sandbox.openprocurement.org/tenders/')]@onclick
  ${url}=    Get Substring    ${auction_url}    13    97
  [return]  ${url}


#                      QUALIFICATION OPERATIONS                     #

Завантажити документ рішення кваліфікаційної комісії
  [Arguments]  ${username}  ${document}  ${tender_uaid}  ${award_num}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Підтвердити постачальника
  [Arguments]  ${username}  ${tender_uaid}  ${award_num}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


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
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


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
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


#                               OPEN PROCUREMENT                                #

Підтвердити кваліфікацію
  [Arguments]  ${username}  ${tender_uaid}  ${qualification_num}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Відхилити кваліфікацію
  [Arguments]  ${username}  ${tender_uaid}  ${qualification_num}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Завантажити документ у кваліфікацію
  [Arguments]  ${username}  ${document}  ${tender_uaid}  ${qualification_num}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Скасувати кваліфікацію
  [Arguments]  ${username}  ${tender_uaid}  ${qualification_num}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Затвердити остаточне рішення кваліфікації
  [Arguments]  ${username}  ${tender_uaid}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


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
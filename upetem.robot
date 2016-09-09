*** Settings ***
Library  Selenium2Screenshots
Library  String
Library  DateTime
Library  upetem_service.py

*** Variables ***
${locator.tenderId}                                            xpath=//*[contains(@class, 'info-tender-id')]//*[@class='value']
${locator.title}                                               xpath=//*[@class='header-wrapper']//h3
${locator.description}                                         xpath=//*[@class='description-wrapper']
${locator.minimalStep.amount}                                  xpath=//*[contains(@class, 'info-min-step')]//*[@class='value']
${locator.procuringEntity.name}                                xpath=//*[@class='company-information-list-wrapper']/*[1]//span
${locator.value.amount}                                        xpath=//*[contains(@class, 'info-budget')]//*[@class='value']
${locator.enquiryPeriod.startDate}                             xpath=//div[@class='date-list-wrapper']/div[1]//span
${locator.enquiryPeriod.endDate}                               xpath=//div[@class='date-list-wrapper']/div[1]//span
${locator.tenderPeriod.startDate}                              xpath=//div[@class='date-list-wrapper']/div[2]//span
${locator.tenderPeriod.endDate}                                xpath=//div[@class='date-list-wrapper']/div[2]//span
${locator.items[0].deliveryDate.endDate}                       xpath=//div[contains(@id, 'collapse')][1]//div[@class='item-wrapper'][4]/span
#${locator.items[0].deliveryLocation.latitude}                  id=delivery_latitude0
#${locator.items[0].deliveryLocation.longitude}                 id=delivery_longitude0
${locator.items[0].deliveryAddress.countryName}                xpath=//span[@class='country']
${locator.items[0].deliveryAddress.postalCode}                 xpath=//span[@class='postal_code']
${locator.items[0].deliveryAddress.region}                     xpath=//span[@class='region']
${locator.items[0].deliveryAddress.locality}                   xpath=//span[@class='locality']
${locator.items[0].deliveryAddress.address}                    xpath=//span[@class='address']
${locator.items[0].description}                                xpath=(//*[@class='panel-heading'])[1]//*[contains(@class, 'description')]
${locator.items[0].classification.scheme}                      xpath=(//*[contains(@class, 'panel-collapse')])[1]//*[@class='item-wrapper'][1]/label
${locator.items[0].classification.id}                          xpath=(//*[contains(@class, 'panel-collapse')])[1]//*[@class='item-wrapper'][1]/span
#${locator.items[0].classification.description}                 xpath=(//*[contains(@class, 'panel-collapse')])[1]//*[@class='item-wrapper'][1]/span
${locator.items[0].additionalClassifications[0].scheme}        xpath=(//*[contains(@class, 'panel-collapse')])[1]//*[@class='item-wrapper'][2]/label
${locator.items[0].additionalClassifications[0].id}            xpath=(//*[contains(@class, 'panel-collapse')])[1]//*[@class='item-wrapper'][2]/span
#${locator.items[0].additionalClassifications[0].description}   xpath=(//*[contains(@class, 'panel-collapse')])[1]//*[@class='item-wrapper'][1]/span
#${locator.items[0].unit.code}                                  xpath=(//*[@class='panel-heading'])[1]//*[contains(@class, 'quantity')]
${locator.items[0].quantity}                                   xpath=(//*[@class='panel-heading'])[1]//*[contains(@class, 'quantity')]

${locator.questions[0].title}                                  xpath=(//div[@class='items'])[last()]//*[@class='title-wrapper']//h4
${locator.questions[0].description}                            xpath=(//div[@class='items'])[last()]//*[@class='question-wrapper'][1]//p
${locator.questions[0].date}                                   xpath=(//div[@class='items'])[last()]//*[@class='author-wrapper']//span
${locator.questions[0].answer}                                 xpath=(//div[@class='items'])[last()]//*[@class='answer-wrapper']//p
${locator.status}                                              xpath=//*[contains(@class, 'opstatus')]
${tender_page_prefix}=                                         http://dz.upetem.com.ua/tender/
${tender_sync_prefix}=                                         http://dz.upetem.com.ua/develop/syncTender/
${tender_sync_postfix}=                                        ?psw=369369

*** Keywords ***
Підготувати дані для оголошення тендера
  [Arguments]  @{ARGUMENTS}
  ${INITIAL_TENDER_DATA}=  test_tender_data
  [return]   ${INITIAL_TENDER_DATA}

Підготувати клієнт для користувача
  [Arguments]  ${username}
  [Documentation]  Відкрити браузер, створити об’єкт api wrapper, тощо
#  Sleep  1
#  Open Browser  ${USERS.users['${username}'].homepage}  ${USERS.users['${username}'].browser}  alias=${username}
  Open Browser  ${BROKERS['upetem'].homepage}  ${USERS.users['${username}'].browser}  alias=${username}
  Set Window Size  @{USERS.users['${username}'].size}
  Set Window Position  @{USERS.users['${username}'].position}
  Login  ${username}

Login
  [Arguments]  ${username}
  Wait Until Element Is Visible  xpath=//*[contains(@class, 'btn-auth1')]  10
  Click Link    xpath=//*[contains(@class, 'btn-auth1')]
  Sleep    1
  Wait Until Page Contains Element   id=UserLoginForm_email   20
  Input text   id=UserLoginForm_email      ${USERS.users['${username}'].login}
  Input text   id=UserLoginForm_password      ${USERS.users['${username}'].password}
  Click Button   xpath=//*[@type='submit']
  Wait Until Page Contains          Закупівлі   20
  #Go To  ${USERS.users['${username}'].homepage}

Створити тендер
  [Arguments]  ${user}  ${tender_data}
  #${tender_data}=   Add_data_for_GUI_FrontEnds  ${ARGUMENTS[1]}
  ${tender_data}=   procuring_entity_name  ${tender_data}
  ${items}=         Get From Dictionary   ${tender_data.data}               items
  ${title}=         Get From Dictionary   ${tender_data.data}               title
  ${description}=   Get From Dictionary   ${tender_data.data}               description
  ${budget}=        Get From Dictionary   ${tender_data.data.value}         amount
  ${budget}=        Convert To String     ${budget}
  ${step_rate}=     Get From Dictionary   ${tender_data.data.minimalStep}   amount
  ${step_rate}=     Convert To String     ${step_rate}
  ${items_description}=   Get From Dictionary   ${items[0]}         description
  ${quantity}=      Get From Dictionary   ${items[0]}                        quantity
  ${quantity}=      Convert To String     ${quantity}
  ${cpv}=           Get From Dictionary   ${items[0].classification}         id
  ${unit}=          Get From Dictionary   ${items[0].unit}                   name
  ${latitude}       Get From Dictionary   ${items[0].deliveryLocation}    latitude
  ${longitude}      Get From Dictionary   ${items[0].deliveryLocation}    longitude
  ${postalCode}    Get From Dictionary   ${items[0].deliveryAddress}     postalCode
  ${streetAddress}    Get From Dictionary   ${items[0].deliveryAddress}     streetAddress
  ${deliveryDate}   Get From Dictionary   ${items[0].deliveryDate}        endDate
  ${start_date}=    Get From Dictionary   ${tender_data.data.tenderPeriod}   startDate
  ${start_date}=    convert_datetime_for_delivery   ${start_date}
  ${end_date}=      Get From Dictionary   ${tender_data.data.tenderPeriod}   endDate
  ${end_date}=      convert_datetime_for_delivery   ${end_date}
  ${enquiry_start_date}=    Get From Dictionary   ${tender_data.data.enquiryPeriod}   startDate
  ${enquiry_start_date}=    convert_datetime_for_delivery   ${enquiry_start_date}
  ${enquiry_end_date}=      Get From Dictionary   ${tender_data.data.enquiryPeriod}   endDate
  ${enquiry_end_date}=      convert_datetime_for_delivery   ${enquiry_end_date}
  
  Selenium2Library.Switch Browser    ${user}
  Go To                             ${USERS.users['${user}'].homepage}
  Wait Until Page Contains          Закупівлі   10
  Sleep  1
  Click Element                     xpath=//*[contains(@class, 'btn-success')]
  Sleep  1
  Wait Until Page Contains          Створення закупівлі  10
  Input text    id=TenderForm_op_title                  ${title}
  Input text    id=TenderForm_op_description            ${description}
  Input text    id=TenderForm_op_value_amount                  ${budget}
  Click Element                     id=TenderForm_op_value_added_tax_included
  Input text    id=TenderForm_op_min_step_amount            ${step_rate}
  Input text    id=TenderForm_op_enquiry_period_start_date        ${enquiry_start_date}
  Input text    id=TenderForm_op_enquiry_period_end_date          ${enquiry_end_date}
  Input text    id=TenderForm_op_tender_period_start_date        ${start_date}
  Input text    id=TenderForm_op_tender_period_end_date          ${end_date}
 
  Додати предмет   ${items[0]}   0
  Run Keyword if   '${mode}' == 'multi'   Додати багато предметів   items
  Sleep  1

  Select Checkbox  id=TenderForm_op_mode
  #Wait Until Page Contains Element   xpath=//*[@type='submit']
  Click Element   xpath=//*[@type='submit']
  Sleep  1
  Wait Until Page Contains   Закупівля успішно створена   10
  #Sleep   2
  ${tender_UAid}=  Get Text  xpath=//*[contains(@class, 'info-tender-id')]//*[@class='value']
  #Log To Console  ${tender_UAid}
  ${Ids}=   Convert To String   ${tender_UAid}
  Save Tender ID
  Log  ${Ids}
  [return]  ${Ids}

Додати предмет
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  item
  ...      ${ARGUMENTS[1]} ==  ${INDEX}
  ${description}=   Get From Dictionary   ${ARGUMENTS[0]}              description
  ${cpv_id}=        Get From Dictionary   ${ARGUMENTS[0].classification}              id
  ${dkpp_id}=       Get From Dictionary   ${ARGUMENTS[0].additionalClassifications[0]}   id
  ${unit}=          Get From Dictionary   ${ARGUMENTS[0].unit}    name
  ${quantity}=      Get From Dictionary   ${ARGUMENTS[0]}         quantity
  ${quantity}=      Convert To String     ${quantity}
  ${region}=        Get From Dictionary   ${ARGUMENTS[0].deliveryAddress}  region
  ${locality}=      Get From Dictionary   ${ARGUMENTS[0].deliveryAddress}  locality
  ${street}=        Get From Dictionary   ${ARGUMENTS[0].deliveryAddress}  streetAddress
  ${code}=          Get From Dictionary   ${ARGUMENTS[0].deliveryAddress}  postalCode
  ${code}=          Convert To String     ${code}
  ${delivery_end}=  Get From Dictionary   ${ARGUMENTS[0].deliveryDate}  endDate
  ${delivery_end}=  convert_datetime_for_delivery  ${delivery_end}

  Sleep  2
  Input text                         xpath=(//*[@data-type='item'])[last()]//input[contains(@id, '_op_description')]  ${description}
  Input text                         xpath=(//*[@data-type='item'])[last()]//input[contains(@id, '_op_quantity')]  ${quantity}
  Select From List By Label          xpath=(//*[@data-type='item'])[last()]//select[contains(@id, '_op_unit_id')]  ${unit}
  
#  Sleep  2
  Click Element                      xpath=(//*[@data-type='item'])[last()]//button[contains(., 'Класифікація ДК 021:2015')]
  Wait Until Element Is Visible      xpath=(//*[@data-type='item'])[last()]//h4[contains(., 'Класифікація ДК 021:2015')]
  Sleep  1
  Input text                         xpath=(//*[@data-type='item'])[last()]//*[@role='document'][contains(.//h4, 'Класифікація ДК 021:2015')]//input[@id='search-input']  ${cpv_id}
  Press key                          xpath=(//*[@data-type='item'])[last()]//*[@role='document'][contains(.//h4, 'Класифікація ДК 021:2015')]//input[@id='search-input']  \\13
  Wait Until Page Contains Element   xpath=(//*[@data-type='item'])[last()]//span[contains(span/b, '${cpv_id}')]  10
  Click Element                      xpath=(//*[@data-type='item'])[last()]//span[span/b/text()='${cpv_id}']/span[@class='fancytree-checkbox']
  Click Element                      xpath=(//*[@data-type='item'])[last()]//*[@role='document'][contains(.//h4, 'Класифікація ДК 021:2015')]//button[contains(@class, 'js-submit-btn')]
  Sleep  1
  
  Click Element                      xpath=(//*[@data-type='item'])[last()]//button[contains(., 'Класифікація ДК 016:2010')]
  Wait Until Element Is Visible      xpath=(//*[@data-type='item'])[last()]//h4[contains(., 'Класифікація ДК 016:2010')]
  Sleep  1
  Input text                         xpath=(//*[@data-type='item'])[last()]//*[@role='document'][contains(.//h4, 'Класифікація ДК 016:2010')]//input[@id='search-input']  ${dkpp_id}
  Press key                          xpath=(//*[@data-type='item'])[last()]//*[@role='document'][contains(.//h4, 'Класифікація ДК 016:2010')]//input[@id='search-input']  \\13
  Wait Until Page Contains Element   xpath=(//*[@data-type='item'])[last()]//span[contains(span/b, '${dkpp_id}')]  10
  Click Element                      xpath=(//*[@data-type='item'])[last()]//span[span/b/text()='${dkpp_id}']/span[@class='fancytree-checkbox']
  Click Element                      xpath=(//*[@data-type='item'])[last()]//*[@role='document'][contains(.//h4, 'Класифікація ДК 016:2010')]//button[contains(@class, 'js-submit-btn')]
  Sleep  1
  # Execute Javascript  $('[name*="op_classification_id"]').eq(${ARGUMENTS[1]}).attr('value', '6272')
  # Execute Javascript  $('[name*="op_additional_classification_ids"]').eq(${ARGUMENTS[1]}).attr('value', '11911')
  Select Checkbox                    xpath=(//*[@data-type='item'])[last()]//*[@type='checkbox'][contains(@id, '_shipping')]
 # Sleep 1
 # Wait For Element Is Visible        xpath=(//*[@data-type='item'])[last()]//select[contains(@id, '_op_delivery_address_region_id')]  10
  Select From List By Label          xpath=(//*[@data-type='item'])[last()]//select[contains(@id, '_op_delivery_address_region_id')]  ${region}
  Sleep  1
  ${has_locality}=  Run Keyword And Return Status  Element Should Contain  xpath=(//*[@data-type='item'])[last()]//select[contains(@id, '_op_delivery_address_locality_id')]  ${locality}
  Run Keyword If  ${has_locality}  Select From List By Label  xpath=(//*[@data-type='item'])[last()]//select[contains(@id, '_op_delivery_address_locality_id')]  ${locality}

  Input Text                        xpath=(//*[@data-type='item'])[last()]//input[contains(@id, '_op_delivery_address_street_address')]  ${street}
  Input Text                        xpath=(//*[@data-type='item'])[last()]//input[contains(@id, '_op_delivery_address_postal_code')]  ${code}
  Input Text                        xpath=(//*[@data-type='item'])[last()]//input[contains(@id, '_op_delivery_date_end_date')]  ${delivery_end}


Додати багато предметів
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  items
  ${Items_length}=   Get Length   ${items}
  : FOR    ${INDEX}    IN RANGE    1    ${Items_length}
  \   Click Element   xpath=//*[contains(@class, 'js-items-add')]
  \   Додати предмет   ${items[${INDEX}]}   ${INDEX}

Клацнути і дочекатися
  [Arguments]  ${click_locator}  ${wanted_locator}  ${timeout}
  [Documentation]
  ...      click_locator: Where to click
  ...      wanted_locator: What are we waiting for
  ...      timeout: Timeout
  Click Element  ${click_locator}
  Wait Until Page Contains Element  ${wanted_locator}  ${timeout}

Шукати і знайти
  Клацнути і дочекатися  xpath=//input[contains(./@class, 'btn-submit')]  xpath=(//*[@class='title-wrapper'])[1]  5

Load And Check Text
  [Arguments]  ${url}  ${wanted_text}
  Go To  ${url}
  Page Should Contain  ${wanted_text}

Load And Wait Text
  [Arguments]  ${url}  ${wanted_text}  ${retries}
  Wait Until Keyword Succeeds  ${retries}x  200ms  Load And Check Text  ${url}  ${wanted_text}

Пошук тендера по ідентифікатору
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  Selenium2Library.Switch browser   ${ARGUMENTS[0]}
  Load And Wait Text  ${BROKERS['upetem'].homepage}  Допорогові закупівлі України  4
  #Go To  ${BROKERS['ubiz'].homepage}
  #Wait Until Page Contains   Допорогові закупівлі України    20
#  sleep  1
  Wait Until Page Contains Element    id=TenderSearchForm_query    20
#  sleep  3  
  Input Text    id=TenderSearchForm_query    ${ARGUMENTS[1]}
#  sleep  1
  ${timeout_on_wait}=  Get Broker Property By Username  ${ARGUMENTS[0]}  timeout_on_wait
  ${passed}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${timeout_on_wait} s  0 s  Шукати і знайти
  Run Keyword Unless  ${passed}  Fatal Error  Тендер не знайдено за ${timeout_on_wait} секунд
  sleep  1
  Wait Until Page Contains Element    xpath=(//*[@class='title-wrapper'])[1]    20
  #sleep  1
  Click Element    xpath=(//*[@class='title-wrapper'])[1]/a
  Sleep  1
  Wait Until Page Contains    ${ARGUMENTS[1]}   60
  Save Tender ID
  Click Element  xpath=//span[@class='expand']
  Wait Until Element Is Visible  ${locator.items[0].classification.id}  10
  #Sleep  1
  Capture Page Screenshot

Завантажити документ
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${filepath}
  ...      ${ARGUMENTS[2]} ==  ${TENDER_UAID}
  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  #ubiz.Пошук тендера по ідентифікатору  ${ARGUMENTS[0]}  ${ARGUMENTS[2]}
  Open Tender
  Wait Until Page Contains  Інформація про закупівлю  20
  Click Element  xpath=//a[text()='Редагувати']
  Sleep  1
  Wait Until Page Contains  Редагування закупівлі  10
  Click Element  xpath=//a[@data-url='/tender/getDocumentForm']
  Wait Until Page Contains Element  xpath=(//div[label/@for='TenderForm_documents']//div[@class='js-item-parent-wrapper'])[last()]//input[@type='file']  10
  Choose File  xpath=(//div[label/@for='TenderForm_documents']//div[@class='js-item-parent-wrapper'])[last()]//input[@type='file']  ${ARGUMENTS[1]}
  Sleep  1
  Click Element   xpath=//*[@type='submit']
  Sleep  1
  Wait Until Page Contains   Дані закупівлі успішно змінені.   10


Подати скаргу
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} ==  ${Complain}
  Fail  Не реалізований функціонал

порівняти скаргу
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${file_path}
  ...      ${ARGUMENTS[2]} ==  ${TENDER_UAID}
  Fail  Не реалізований функціонал

Подати цінову пропозицію
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} ==  ${test_bid_data}
  ${bid}=                     Get From Dictionary   ${ARGUMENTS[2].data.value}         amount
  upetem.Оновити сторінку з тендером   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Click Element               xpath=//div[@class='actions-wrapper']//a
  Sleep  1
  Wait Until Page Contains    Реєстрація пропозиції по закупівлі    10
  Input text                  xpath=(//input[contains(@id, '_op_value_amount')])[1]  ${bid}
  Click Element               xpath=//form[@id='tender-bid-form']//input[@type='submit']
  Sleep  1
  #ubiz.Оновити сторінку з тендером  ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  #Wait Until Page Contains    Пропозиція успішно додана.  10

Змінити цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}  ${amount_locator}  ${new_sum}
  #ubiz.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Open Tender
  Page Should Contain Element  xpath=//div[@class='actions-wrapper']//a[contains(@class, 'btn-info')]
  Click Element                xpath=//div[@class='actions-wrapper']//a[contains(@class, 'btn-info')]
  Sleep  1
  Wait Until Page Contains    Редагування пропозиції по закупівлі    10
  Input text                  xpath=(//input[contains(@id, '_op_value_amount')])[1]  ${new_sum}
  Click Element               xpath=//form[@id='tender-bid-form']//input[@type='submit']
  Sleep  1
  #ubiz.Оновити сторінку з тендером  ${provider}  ${tender_uaid}

Завантажити документ в ставку
  [Arguments]  ${provider}  ${filepath}  ${tender_uaid}
  #ubiz.Пошук тендера по ідентифікатору  ${provider}  ${tender_uaid}
  Open Tender
  Page Should Contain Element  xpath=//div[@class='actions-wrapper']//a[contains(@class, 'btn-info')]
  Click Element                xpath=//div[@class='actions-wrapper']//a[contains(@class, 'btn-info')]
  Sleep  1
  Wait Until Page Contains    Редагування пропозиції по закупівлі    10
  Click Element               xpath=//a[contains(@class, 'js-items-add')]
  Wait Until Page Contains Element  xpath=//input[@type='file']  10
  Choose File                 xpath=//input[@type='file']  ${filepath}
  Sleep  1
  Click Element               xpath=//form[@id='tender-bid-form']//input[@type='submit']
  Sleep  1
  #ubiz.Оновити сторінку з тендером  ${provider}  ${tender_uaid}

Змінити документ в ставці
  [Arguments]  ${username}  ${filepath}  ${bidid}  ${docid}
  ${tender_name}=  Get From Dictionary  ${USERS.users['${tender_owner}'].initial_data.data}  title
  #ubiz.Пошук тендера по ідентифікатору  ${provider}  ${tender_name}
  Open Tender
  Page Should Contain Element  xpath=//div[@class='actions-wrapper']//a[contains(@class, 'btn-info')]
  Click Element                xpath=//div[@class='actions-wrapper']//a[contains(@class, 'btn-info')]
  Sleep  1
  Wait Until Page Contains    Редагування пропозиції по закупівлі    10
  Choose File                 xpath=//input[@type='file']  ${filepath}
  Sleep  1
  Click Element               xpath=//form[@id='tender-bid-form']//input[@type='submit']
  Sleep  1
  #ubiz.Оновити сторінку з тендером  ${provider}  ${tender_name}

скасувати цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}  ${bid_response}
  #ubiz.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Open Tender
  Page Should Contain Element  xpath=//div[@class='actions-wrapper']//a[contains(@class, 'btn-danger')]
  Click Element                xpath=//div[@class='actions-wrapper']//a[contains(@class, 'btn-danger')]
  Sleep  1
  Wait Until Page Contains     Пропозиція успішно видалена.  10

Оновити сторінку з тендером
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} =  username
  ...      ${ARGUMENTS[1]} =  ${TENDER_UAID}
  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  Sync Tender
  Open Tender
  #ubiz.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  
Задати питання
  [Arguments]  ${username}  ${tender_uaid}  ${question}

  ${title}=        Get From Dictionary  ${question.data}  title
  ${description}=  Get From Dictionary  ${question.data}  description

  Selenium2Library.Switch Browser    ${username}
  #ubiz.Пошук тендера по ідентифікатору   ${username}  ${tender_uaid}
  Open Tender
  #Wait date  ${USERS.users['${tender_owner}'].initial_data.data.enquiryPeriod.startDate}
  Switch To Questions
  Input text                         id=TenderQuestionForm_op_title               ${title}
  Input text                         id=TenderQuestionForm_op_description           ${description}
  Sleep  2
  Click Element                      xpath=//*[@type='submit']
  Sleep  1
  #Click Element                      xpath=//*[@type='submit']
  #Sleep  1
  #Click Element                       xpath=//input[@value='Задати питання']
  #Sleep  1
  Wait Until Page Contains            Питання успішно додане.  10

Відповісти на питання
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} = username
  ...      ${ARGUMENTS[1]} = ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} = 0
  ...      ${ARGUMENTS[3]} = answer_data

  ${answer}=     Get From Dictionary  ${ARGUMENTS[3].data}  answer

  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  #ubiz.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Open Tender
  Switch To Questions
  Input text                         id=TenderQuestionAnswerForm_op_answer               ${answer}
  Click Element                      xpath=//*[@type='submit']
  Sleep  1
  Wait Until Page Contains           Відповідь успішно додана.  10
  Capture Page Screenshot

Внести зміни в тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} =  username
  ...      ${ARGUMENTS[1]} =  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} =  field_locator (description)
  ...      ${ARGUMENTS[3]} =  text
  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  #ubiz.Пошук тендера по ідентифікатору  ${ARGUMENTS[0]}  ${ARGUMENTS[1]}
  Open Tender
  Wait Until Page Contains  Інформація про закупівлю  20
  Click Element  xpath=//a[text()='Редагувати']
  Sleep  1
  Wait Until Page Contains  Редагування закупівлі  10
  Input text    id=TenderForm_op_description            ${ARGUMENTS[3]}
  Click Element   xpath=//*[@type='submit']
  Sleep  1
  Wait Until Page Contains   Дані закупівлі успішно змінені.   10
  Capture Page Screenshot

додати предмети закупівлі
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} =  username
  ...      ${ARGUMENTS[1]} =  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} =  3
  ${period_interval}=  Get Broker Property By Username  ${ARGUMENTS[0]}  period_interval
  ${ADDITIONAL_DATA}=  prepare_test_tender_data  ${period_interval}  multi
  ${tender_data}=   Add_data_for_GUI_FrontEnds   ${ADDITIONAL_DATA}
  ${items}=         Get From Dictionary   ${tender_data.data}               items
  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  Run keyword if   '${TEST NAME}' == 'Можливість додати позицію закупівлі в тендер'   додати позицію
  Run keyword if   '${TEST NAME}' != 'Можливість додати позицію закупівлі в тендер'   видалити позиції

додати позицію
  upetem.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Sleep  2
  Click Element                     xpath=//a[@class='btn btn-primary ng-scope']
  Sleep  2
  : FOR    ${INDEX}    IN RANGE    1    ${ARGUMENTS[2]} +1
  \   Click Element   xpath=.//*[@id='myform']/tender-form/div/button
  \   Додати предмет   ${items[${INDEX}]}   ${INDEX}
  Sleep  2
  Click Element   xpath=//div[@class='form-actions']/button[./text()='Зберегти зміни']
  Wait Until Page Contains    [ТЕСТУВАННЯ]   10

видалити позиції
  upetem.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Click Element                     xpath=//a[@class='btn btn-primary ng-scope']
  Sleep  2
  : FOR    ${INDEX}    IN RANGE    1    ${ARGUMENTS[2]} +1
  \   Click Element   xpath=(//button[@class='btn btn-danger ng-scope'])[last()]
  \   Sleep  1
  Sleep  2
  Wait Until Page Contains Element   xpath=//div[@class='form-actions']/button[./text()='Зберегти зміни']   10
  Click Element   xpath=//div[@class='form-actions']/button[./text()='Зберегти зміни']
  Wait Until Page Contains    [ТЕСТУВАННЯ]   10

Отримати інформацію із тендера
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  fieldname
  Switch browser   ${ARGUMENTS[0]}
  Run Keyword If  'question' in '${ARGUMENTS[1]}'  Switch To Questions
  Run Keyword And Return If  'status' in '${ARGUMENTS[1]}'  Отримати інформацію про ${ARGUMENTS[1]}  ${ARGUMENTS[0]}  ${TENDER.TENDER_UAID}
  Run Keyword And Return  Отримати інформацію про ${ARGUMENTS[1]}

Отримати текст із поля і показати на сторінці
  [Arguments]   ${fieldname}
  #sleep  3
#  відмітити на сторінці поле з тендера   ${fieldname}   ${locator.${fieldname}}
  Wait Until Page Contains Element    ${locator.${fieldname}}    22
  #Sleep  1
  ${return_value}=   Get Text  ${locator.${fieldname}}
  [return]  ${return_value}

Отримати інформацію про title
  ${return_value}=   get_text_excluding_children  ${locator.title}
  ${return_value}=   Strip String  ${return_value}
  [return]  ${return_value}

Отримати інформацію про description
  ${return_value}=   Отримати текст із поля і показати на сторінці   description
  [return]  ${return_value}

Отримати інформацію про minimalStep.amount
  ${return_value}=   Отримати текст із поля і показати на сторінці   minimalStep.amount
  ${return_value}=  Evaluate  ''.join('${return_value}'.split()[:-1])
  ${return_value}=   Convert To Number   ${return_value}
  [return]  ${return_value}

Отримати інформацію про value.amount
  ${return_value}=   Отримати текст із поля і показати на сторінці  value.amount
  ${return_value}=  Evaluate  ''.join('${return_value}'.split()[:-3])
  ${return_value}=   Convert To Number   ${return_value}
  [return]  ${return_value}

Отримати інформацію про value.currency
  [return]  UAH
#  ${return_value}=   Отримати текст із поля і показати на сторінці  value.amount
#  ${return_value}=   Evaluate   "".join("${return_value}".split(' ')[:-3])
#  ${return_value}=   Convert To Number   ${return_value}
#  [return]  ${return_value}

Отримати інформацію про value.valueAddedTaxIncluded
  ${return_value}=   Отримати текст із поля і показати на сторінці  value.amount
  ${return_value}=  Run Keyword If  'ПДВ' in '${return_value}'  Set Variable  True
    ...  ELSE Set Variable  False
  Log  ${return_value}
  ${return_value}=   Convert To Boolean   ${return_value}
  [return]  ${return_value}

Відмітити на сторінці поле з тендера
  [Arguments]   ${fieldname}  ${locator}
  ${last_note_id}=  Add pointy note   ${locator}   Found ${fieldname}   width=200  position=bottom
  Align elements horizontally    ${locator}   ${last_note_id}
  sleep  1
  Remove element   ${last_note_id}

Отримати інформацію про tenderId
  ${return_value}=   Отримати текст із поля і показати на сторінці   tenderId
  [return]  ${return_value}

Отримати інформацію про procuringEntity.name
  ${return_value}=   Отримати текст із поля і показати на сторінці   procuringEntity.name
  [return]  ${return_value}

Отримати інформацію про enquiryPeriod.startDate
  ${return_value}=   Отримати текст із поля і показати на сторінці  enquiryPeriod.startDate
  ${return_value}=   Split String  ${return_value}  -
  ${return_value}=   Strip String  ${return_value[0]}
  ${return_value}=   convert_date_for_compare   ${return_value}
  [return]  ${return_value}

Отримати інформацію про enquiryPeriod.endDate
  ${return_value}=   Отримати текст із поля і показати на сторінці  enquiryPeriod.endDate
  ${return_value}=   Split String  ${return_value}  -
  ${return_value}=   Strip String  ${return_value[1]}
  ${return_value}=   convert_date_for_compare   ${return_value}
  [return]  ${return_value}

Отримати інформацію про tenderPeriod.startDate
  ${return_value}=   Отримати текст із поля і показати на сторінці  tenderPeriod.startDate
  ${return_value}=   Split String  ${return_value}  -
  ${return_value}=   Strip String  ${return_value[0]}
  ${return_value}=   convert_date_for_compare   ${return_value}
  [return]  ${return_value}

Отримати інформацію про tenderPeriod.endDate
  ${return_value}=   Отримати текст із поля і показати на сторінці  tenderPeriod.endDate
  ${return_value}=   Split String  ${return_value}  -
  ${return_value}=   Strip String  ${return_value[1]}
  ${return_value}=   convert_date_for_compare   ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].description
  ${return_value}=   Отримати текст із поля і показати на сторінці   items[0].description
  [return]  ${return_value}

Отримати інформацію про items[0].unit.code
  ${return_value}=   Отримати текст із поля і показати на сторінці   items[0].quantity
  ${return_value}=   Split String  ${return_value}  max_split=1
  Run Keyword And Return If  '${return_value[1]}'== 'кілограми'   Convert To String  KGM
  [return]  ${return_value}

Отримати інформацію про items[0].unit.name
  ${return_value}=   Отримати текст із поля і показати на сторінці   items[0].quantity
  ${return_value}=   Split String  ${return_value}  max_split=1
  [return]  ${return_value[1]}

Отримати інформацію про items[0].quantity
  ${return_value}=   Отримати текст із поля і показати на сторінці   items[0].quantity
  ${return_value}=   Split String  ${return_value}  max_split=1
  ${return_value}=   Convert To Number  ${return_value[0]}
  [return]  ${return_value}

Отримати інформацію про items[0].classification.scheme  
  [return]  CPV
  #${return_value}=   Отримати текст із поля і показати на сторінці  items[0].classification.scheme
  #${return_value}=   Get Substring  ${return_value}  start=0  end=-1
  #${return_value}=   Split String From Right  ${return_value}  max_split=1
  #[return]  ${return_value[1]}

Отримати інформацію про items[0].classification.id
  ${return_value}=   Отримати текст із поля і показати на сторінці  items[0].classification.id
  ${return_value}=   Split String  ${return_value}  max_split=1
  [return]  ${return_value[0]}

Отримати інформацію про items[0].classification.description
  ${return_value}=   Отримати текст із поля і показати на сторінці  items[0].classification.id
  ${return_value}=   Split String  ${return_value}  max_split=1
  [return]  ${return_value[1]}

Отримати інформацію про items[0].additionalClassifications[0].scheme
  [return]  ДКПП
  #${return_value}=   Отримати текст із поля і показати на сторінці  items[0].additionalClassifications[0].scheme
  #${return_value}=   Get Substring  ${return_value}  start=0  end=-1
  #${return_value}=   Split String From Right  ${return_value}  max_split=1
  #[return]  ${return_value[1]}

Отримати інформацію про items[0].additionalClassifications[0].id
  ${return_value}=   Отримати текст із поля і показати на сторінці  items[0].additionalClassifications[0].id
  ${return_value}=   Split String  ${return_value}
  [return]  ${return_value[0]}

Отримати інформацію про items[0].additionalClassifications[0].description
  ${return_value}=  Отримати текст із поля і показати на сторінці  items[0].additionalClassifications[0].id
  ${return_value}=   Split String  ${return_value}  max_split=1
  [return]  ${return_value[1]}

Отримати інформацію про items[0].deliveryAddress.postalCode
  ${return_value}=  Отримати текст із поля і показати на сторінці  items[0].deliveryAddress.postalCode
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.countryName
  ${return_value}=  Отримати текст із поля і показати на сторінці  items[0].deliveryAddress.countryName
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.region
  ${return_value}=  Отримати текст із поля і показати на сторінці  items[0].deliveryAddress.region
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.locality
  ${return_value}=  Отримати текст із поля і показати на сторінці  items[0].deliveryAddress.locality
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.streetAddress
  ${return_value}=  Отримати текст із поля і показати на сторінці  items[0].deliveryAddress.address
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryDate.endDate
  ${return_value}=  Отримати текст із поля і показати на сторінці  items[0].deliveryDate.endDate
  ${return_value}=   Split String  ${return_value}  max_split=1
  ${return_value}=   convert_date_for_compare   ${return_value[1]}
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryLocation.latitude
  Fail  Координати не підтримуються майданчиком

Отримати інформацію про items[0].deliveryLocation.longitude
  Fail  Координати не підтримуються майданчиком

Отримати інформацію про questions[0].title
  Run Keyword And Return  get_text_excluding_children  ${locator.questions[0].title}

Отримати інформацію про questions[0].description
  Run Keyword And Return  get_text_excluding_children  ${locator.questions[0].description}

Отримати інформацію про questions[0].date
  ${return_value}=  get_text_excluding_children  ${locator.questions[0].date}
  Run Keyword And Return  convert_date_for_compare  ${return_value}

Отримати інформацію про questions[0].answer
  Run Keyword And Return  get_text_excluding_children  ${locator.questions[0].answer}

Отримати інформацію про status
  [Arguments]  ${username}  ${tenderId}
  Sync Tender
  Open Tender
  ${return_value}=   get_invisible_text  ${locator.status}
  #${time}=  Get Time
  #${str}=  Catenate  ${time}  ${return_value}
  #Log To Console  ${str}
  [return]  ${return_value}

Отримати посилання на аукціон для глядача
  [Arguments]  ${username}  ${tenderId}
  Run Keyword And Return  Отримати посилання на аукціон  ${username}  ${tenderId}

Отримати посилання на аукціон для учасника
  [Arguments]  ${username}  ${tenderId}
  Run Keyword And Return  Отримати посилання на аукціон  ${username}  ${tenderId}

Отримати посилання на аукціон
  [Arguments]  ${username}  ${tenderId}
  Selenium2Library.Switch browser  ${username}
  upetem.Оновити сторінку з тендером  ${username}  ${tenderId}
  Run Keyword And Return  Get Text  xpath=//div[contains(@class, 'auction-link-wrapper')]//a



Wait date
  [Arguments]  ${date}
  ${sleep}=  wait_to_date  ${date}
  Run Keyword If  ${sleep} > 0  Sleep  ${sleep}

Switch To Questions
  Click Element                      xpath=//a[contains(., 'Питання/Відповіді')]
  Wait Until Page Contains           Питання та відповіді   10

Save tender ID
  ${status}=  Run keyword And Return Status  Dictionary Should Not Contain Key  ${TENDER}  TENDER_ID
  Run Keyword If  ${status}  Add id to tender

Add id to tender
  ${url}=   Log Location
  ${tender_id}=  Split String From Right  ${url}  /  max_split=1
  Set To Dictionary  ${TENDER}  TENDER_ID=${tender_id[1]}

Get Tender Sync Url
  [Arguments]  ${tender_id}
  Run Keyword And Return  Catenate  SEPARATOR=  ${tender_sync_prefix}  ${tender_id}  ${tender_sync_postfix}  

Sync Tender
  ${status}=  Run keyword And Return Status  Dictionary Should Not Contain Key  ${TENDER}  TENDER_ID
  Run Keyword And Return If  ${status}  Go To  ${BROKERS['upetem'].syncpage}
  ${tender_id}=  Get From Dictionary  ${TENDER}  TENDER_ID
  ${sync_url}=  Get Tender Sync Url  ${tender_id}
  Go To  ${sync_url}

Open Tender
  ${no_id}=  Run Keyword And Return Status  Dictionary Should Not Contain Key  ${TENDER}  TENDER_ID
  Return From Keyword If  ${no_id}
  ${tender_id}=  Get From Dictionary  ${TENDER}  TENDER_ID
  ${tender_url}=  Catenate  SEPARATOR=  ${tender_page_prefix}  ${tender_id}  
  Go To  ${tender_url}
  Sleep  1
# coding=utf-8


def get_procurement_type_xpath(mode):
    procurement_type_xpath = {
        "belowThreshold": "//*[@id='mForm:procurementType_0']",
        "openua": "//*[@id='mForm:procurementType_2']",
        "openeu": "//*[@id='mForm:procurementType_3']",
        "negotiation": "//*[@id='mForm:procurementType_4']"
    }
    return procurement_type_xpath[mode] 


def get_item_xpath(field_name, item_id):
    item_xpath = {
        'description': "//*[contains(text(), '" + item_id + "')]",
        'deliveryDate.startDate': "//*[contains(text(), '" + item_id + "')]//ancestor::table//tr[4]/td[4]/input",
        'deliveryDate.endDate': "//*[contains(text(), '" + item_id + "')]//ancestor::table//tr[5]/td[4]/input",
        'deliveryLocation.latitude': "//*[contains(text(), '" + item_id + "')]//ancestor::table//tr[10]/td[4]//tr[1]//input",
        'deliveryLocation.longitude': "//*[contains(text(), '" + item_id + "')]//ancestor::table//tr[10]/td[4]//tr[2]//input",
        'deliveryAddress.countryName': "//*[contains(text(), '" + item_id + "')]//ancestor::table//tr[7]/td[4]/span",
        'deliveryAddress.postalCode': "//*[contains(text(), '" + item_id + "')]//ancestor::table//tr[9]/td[2]/input",
        'deliveryAddress.region': "//*[contains(text(), '" + item_id + "')]//ancestor::table//tr[8]/td[2]/input",
        'deliveryAddress.locality': "//*[contains(text(), '" + item_id + "')]//ancestor::table//tr[8]/td[4]//input",
        'deliveryAddress.streetAddress': "//*[contains(text(), '" + item_id + "')]//ancestor::table//tr[10]/td[2]/input",
        'classification.scheme': "//*[contains(text(), '" + item_id + "')]//ancestor::table//tr[3]/td[1]/label",
        'classification.id': "//*[contains(text(), '" + item_id + "')]//ancestor::table//tr[2]/td[2]/span/input",
        'classification.description': "//*[contains(text(), '" + item_id + "')]//ancestor::table//tr[3]/td[2]/span",
        'additionalClassifications.scheme': "//*[contains(text(), '" + item_id + "')]//ancestor::table//tr[3]/td[3]/label",
        'additionalClassifications.id': "//*[contains(text(), '" + item_id + "')]//ancestor::table//tr[2]/td[4]//input",
        'additionalClassifications.description': "//*[contains(text(), '" + item_id + "')]//ancestor::table//tr[3]/td[4]/span",
        'unit.name': "//*[contains(text(), '" + item_id + "')]//ancestor::table//tr[4]/td[2]//input",
        'unit.code': "//*[contains(text(), '" + item_id + "')]//ancestor::table//tr[4]/td[2]//input",
        'quantity': "//*[contains(text(), '" + item_id + "')]//ancestor::table//tr[5]/td[2]/input"
    }
    return item_xpath[field_name]


def get_lot_xpath(field_name, lot_id, mode):
    if mode == 'openeu':
        index = '8'
    else:
        index = '7'
    lot_xpath = {
        'title': "//*[contains(@value, '" + lot_id + "')]",
        'description': "//*[contains(@value, '" + lot_id + "')]//ancestor::tbody/tr[4]/td[2]/textarea",
        'value.amount': "//*[contains(@value, '" + lot_id + "')]//ancestor::tbody/tr["+index+"]/td[2]/input",
        'value.currency': "//*[@id='mForm:currency_label']",
        'minimalStep.currency': "//*[@id='mForm:currency_label']",
        'value.valueAddedTaxIncluded': "//*[contains(@value, '" + lot_id + "')]//ancestor::tbody/tr[9]/td[2]//td[1]//input",
        'minimalStep.amount': "//*[contains(@value, '" + lot_id + "')]//ancestor::tbody/tr["+index+"]/td[4]/input",
        'minimalStep.valueAddedTaxIncluded': "//*[contains(@value, '" + lot_id + "')]//ancestor::tbody/tr[9]/td[2]//td[1]//input"
    }
    return lot_xpath[field_name]


def get_document_xpath(field, doc_id):
    doc_xpath = {
        'title': "//*[@id='mForm:pnlFiles']//a[contains(text(), '" + doc_id + "')]",
    }
    return doc_xpath[field]


def get_question_xpath(field_name, question_id):
    question_xpath = {
        'title': "//span[contains(text(), '" + question_id + "')]",
        'description': "(//span[contains(text(), '" + question_id + "')]//ancestor::div[@id='mForm:data_content']//span)[2]",
        'answer': "//*[contains(text(), '" + question_id + "')]//ancestor::div[2]/div[2]/div[2]/div[1]/span[2]"
    }
    return question_xpath[field_name]


def get_claims_xpath(field_name):
    claims_xpath = {
        'title': "//*[@id='mForm:data:title']",
        'description': "//*[@id='mForm:data:description']",
        'status': "//*[text()='Статус']//ancestor::tr/td[2]",
        'resolutionType': "//*[@id='mForm:data:resolutionType_label']",
        'resolution': "//*[@id='mForm:data:resolution']",
        'satisfied': "//*[@id='mForm:data:satisfied_label']",
        'complaintID': "//*[@id='mForm:NBid']",
        'cancellationReason': "//*[@id='mForm:data:cancellationReason']"
    }
    return claims_xpath[field_name]


def get_bid_xpath(field, lot_id):
    lot_id = lot_id[0]
    if field == 'status':
        xpath = "//*[@id='mForm:top']/div[2]/div[2]/div[1]/table//tr[5]/td[2]"
    else:
        xpath = "(//*[contains(text(), '" + lot_id + "')])[2]//ancestor::tbody/tr[7]/td[2]/div/input"
    return xpath

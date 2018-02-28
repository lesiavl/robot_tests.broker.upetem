# coding=utf-8
from datetime import datetime, timedelta
import dateutil.parser
import pytz
import urllib

TZ = pytz.timezone('Europe/Kiev')


def adapt_data(data):
    
    data['data']['procuringEntity']['name'] = 'testuser_tender_owner'
    for x in data['data']['items']:
        x['unit']['name'] = get_unit_name(x['unit']['name'])
        x['deliveryAddress']['region'] = get_delivery_region(x['deliveryAddress']['region'])
        x['deliveryAddress']['locality'] = convert_locality(x['deliveryAddress']['locality'])
        x['deliveryDate']['startDate'] = adapt_delivery_date(x['deliveryDate']['startDate'])
        x['deliveryDate']['endDate'] = adapt_delivery_date(x['deliveryDate']['endDate'])
    data['data']['procuringEntity']['address']['region'] = get_delivery_region(data['data']['procuringEntity']['address']['region'])
    data['data']['procuringEntity']['address']['locality'] = convert_locality(data['data']['procuringEntity']['address']['locality'])
    data['data']['procuringEntity']['contactPoint']['telephone'] = data['data']['procuringEntity']['contactPoint']['telephone'][:13]
    return data


def adapt_step(data, new_step):
    data['data']['minimalStep']['amount'] = round(new_step, 2)
    data['data']['lots'][0]['minimalStep']['amount'] = round(new_step, 2)


def adapt_unit_name(data):
    return {
        u"наб.": u"набір",
        u"шт.": u"штуки",
        u"упак.": u"упаковка",
        u"Флакон": u"флакон"
    }.get(data, data)


def adapt_data_view(data):
    for x in data['data']['items']:
        x['deliveryDate']['startDate'] = adapt_delivery_date(x['deliveryDate']['startDate'])
        x['deliveryDate']['endDate'] = adapt_delivery_date(x['deliveryDate']['endDate'])
    return data


def download_file(url, file_name, output_dir):
    urllib.urlretrieve(url, ('{}/{}'.format(output_dir, file_name)))


def get_type_field(field):
    value = ['deliveryDate.startDate', 'deliveryDate.endDate', 'deliveryAddress.postalCode', 'deliveryAddress.region',
             'deliveryAddress.streetAddress',
             'additionalClassifications.id', 'classification.id', 'unit.name', 'unit.code', 'deliveryLocation.latitude',
             'deliveryLocation.longitude', 'quantity', 'deliveryAddress.locality',
             'title', 'value.amount', 'value.valueAddedTaxIncluded', 'minimalStep.amount',
             'minimalStep.valueAddedTaxIncluded']

    text = ['description', 'deliveryAddress.countryName', 'classification.scheme', 'classification.description',
            'additionalClassifications.scheme', 'additionalClassifications.description',
            'value.currency', 'minimalStep.currency', 'featureOf', 'status', 'resolutionType', 'resolution', 'satisfied', 'complaintID', 'cancellationReason']

    if field in value:
        type_fields = 'value'
    elif field in text:
        type_fields = 'text'
    return type_fields
                       

def get_delivery_region(region):
    if region == u"місто Київ":
        delivery_region = u"м.Київ"
    elif region == u"Дніпропетровська область":
        delivery_region = u"Днiпропетровська область"
    elif region == u"Рівненська область":
        delivery_region = u"Рiвненська область"
    elif region == u"Чернігівська область":
        delivery_region = u"Чернiгiвська область"
    else: delivery_region = region
    return delivery_region


def convert_float_to_string(number):
    return format(number, '.2f')


def convert_coordinates_to_string(number):
    return format(number)


def adapt_delivery_date(date):
    adapt_date = ''.join([date[:date.index('T') + 1], '00:00:00', date[date.index('+'):]])
    return adapt_date


def parse_date(date_str):
    date_str = datetime.strptime(date_str, "%d.%m.%Y %H:%M")
    date = datetime(date_str.year, date_str.month, date_str.day, date_str.hour, date_str.minute, date_str.second,
                    date_str.microsecond)
    date = TZ.localize(date).isoformat()
    return date


def parse_item_date(date_str):
    date_str = datetime.strptime(date_str, "%d.%m.%Y")
    date = datetime(date_str.year, date_str.month, date_str.day)
    date = TZ.localize(date).isoformat()
    return date


def convert_date_to_string(date):
    date = dateutil.parser.parse(date)
    date = date.strftime("%d.%m.%Y %H:%M")
    return date


def convert_item_date_to_string(date):
    date = dateutil.parser.parse(date)
    date = date.strftime("%d.%m.%Y")
    return date


def parse_complaintPeriod_date(date_string):
    date_str = datetime.strptime(date_string, "%d.%m.%Y %H:%M")
    date_str -= timedelta(minutes=5)
    date = datetime(date_str.year, date_str.month, date_str.day, date_str.hour, date_str.minute, date_str.second,
                    date_str.microsecond)
    date = TZ.localize(date).isoformat()
    return date

def parse_complaintPeriod_endDate(date_str):
    if '-' in date_str:
        date_str = datetime.strptime(date_str, "%Y-%m-%d %H:%M:%S")
    else:
        date_str = datetime.strptime(date_str, "%d.%m.%Y %H:%M")
    date = datetime(date_str.year, date_str.month, date_str.day, date_str.hour, date_str.minute, date_str.second,
                    date_str.microsecond)
    date = TZ.localize(date).isoformat()
    return date


def capitalize_first_letter(string):
    string = string.capitalize()
    return string


def get_unit_name(name):
    return {
        u'штуки': u'шт.',
        u'упаковка': u'упак.',
        u'набір': u'наб.',
        u'кілограми': u'кг.',
        u'лот': u'лот',
        u'флакон': u'флак.',
        u'Флакон': u'флак.'
    }.get(name, name)


def convert_locality(name):
    if name == u"Київ":
        adapted_name = u"М.КИЇВ"
    elif name == u"Дніпропетровськ":
        adapted_name = u"ДНІПРОПЕТРОВСЬКА ОБЛАСТЬ/М.ДНІПРО"
    else:
        adapted_name = name
    return adapted_name.upper()


def convert_status(tender_status):
    status = {
        u'Очікування пропозицій': u'active.tendering',
        u'Період аукціону': u'active.auction',
        u'Період уточнень': u'active.enquiries',
        u'Перед-кваліфікаційний період': u'active.pre-qualification',
        u'Блокування перед аукціоном': u'active.pre-qualification.stand-still'
    }
    return status[tender_status]


def get_claim_status(claim_status, test_name):
    status = {
        u'Вимога': 'claim',
        u'Розглянуто': 'answered',
        u'Вирішена': 'resolved',
        u'Відхилено': 'cancelled',
        u'Відхилена': 'declined',
        u'Обробляється': 'pending',
        u'Недійсна': 'invalid',
        u'Проігнорована': 'ignored'
    }
    return status[claim_status]


def get_resolution_type(resolution):
    types = {
        u'Вирішено': 'resolved',
        u'Відхилено': 'declined',
        u'Недійсно': 'invalid'
    }
    return types[resolution]


def convert_satisfied(value):
    if value == u'Так':
        satisfied = True
    else:
        satisfied = False
    return satisfied


def get_unit(field,unit_data):
    unit = unit_data.split()
    unit[1] = adapt_unit_name(unit[1])
    unit_value = {
        'unit.code': unit[0],
        'unit.name': unit[1]
    }
    return unit_value[field]


def convert_type_tender(key):
    type_tender = {
        u'Відкриті торги': 'aboveThresholdUA',
        u'Відкриті торги з публікацією англ.мовою': 'aboveThresholdEU',
        u'Переговорна процедура': 'reporting'
    }
    return type_tender[key]


def convert_data_lot(key):
    data_lot = {
        u'грн.': 'UAH'
    }
    return data_lot[key]


def convert_data_feature(key):
    data_feature = {
        u'Закупівлі': 'tenderer',
        u'Лоту': 'lot',
        u'Предмету лоту': 'item'
    }
    return data_feature[key]


def convert_complaintID(tender_uaid, type_complaint):
    if 'complaint_number' not in globals():
        complaint_number = 1
    value = '%s.a%s' % (tender_uaid, complaint_number)
    global complaint_number
    complaint_number += 1
    return value


def get_pos(featureOf):
    if featureOf == u'Закупівлі':
        position = 1
    elif featureOf == u'Лоту':
        position = 2
    elif featureOf == u'Предмету лоту':
        position = 1
    return position


def get_value_feature(value):
    value = value * 100
    value = str(int(value)) + '%'
    return value


def get_feature_xpath(field_name, feature_id):
    xpath = {
        'title': "//*[contains(@value, '" +feature_id+ "')]",
        'description': "//*[contains(@value, '" +feature_id+ "')]/ancestor::tbody/tr[2]/td[2]/textarea",
        'featureOf': "//*[contains(@value, '" +feature_id+ "')]/ancestor::tbody/tr[3]/td[2]//td[2]/div[1]/label"
    }
    return xpath[field_name]


def convert_bid_status(value):
    status = {
        u'Недійсна пропозиція': 'invalid'
    }
    return status[value]


def get_all_dates(initial_tender_data, key):
    tender_period = initial_tender_data.data.tenderPeriod
    start_dt = dateutil.parser.parse(tender_period['startDate'])
    end_dt = dateutil.parser.parse(tender_period['endDate'])
    data = {
        'EndPeriod': start_dt.strftime("%d.%m.%Y %H:%M"),
        'StartDate': start_dt.strftime("%d.%m.%Y %H:%M"),
        'EndDate': end_dt.strftime("%d.%m.%Y %H:%M"),
    }
    return data.get(key, '')


def increment_identifier(data):
    data['data']['procuringEntity']['identifier']['id'] = str(int(data['data']['procuringEntity']['identifier']['id']) + 1)


def convert_cause_type(key):
    cause_type = {
        '1': 'artContestIP',
        '2': 'noCompetition',
        '4': 'twiceUnsuccessful',
        '5': 'additionalPurchase',
        '6': 'additionalConstruction',
        '7': 'stateLegalServices',
    }
    return cause_type[key]

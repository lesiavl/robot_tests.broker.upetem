# coding=utf-8
from datetime import datetime, timedelta
import dateutil.parser
import pytz
import urllib

TZ = pytz.timezone('Europe/Kiev')


def adapt_data(data):
    
    data['data']['procuringEntity']['name'] = 'testuser_tender_owner'
    data['data']['items'][0]['unit']['name'] = get_unit_name(data['data']['items'][0]['unit']['name'])
    data['data']['items'][0]['deliveryAddress']['region'] = get_delivery_region(data['data']['items'][0]['deliveryAddress']['region'])
    data['data']['items'][0]['deliveryAddress']['locality'] = convert_locality(data['data']['items'][0]['deliveryAddress']['locality'])
    data['data']['items'][0]['deliveryDate']['startDate'] = adapt_delivery_date(data['data']['items'][0]['deliveryDate']['startDate'])
    data['data']['items'][0]['deliveryDate']['endDate'] = adapt_delivery_date(data['data']['items'][0]['deliveryDate']['endDate'])
    return data


def adapt_unit_name(data):
    return {
        u"наб.": u"набір",
        u"шт.": u"штуки",
        u"упак.": u"упаковка"
    }.get(data, data)


def adapt_data_view(data):
    data['data']['items'][0]['deliveryDate']['startDate'] = adapt_delivery_date(data['data']['items'][0]['deliveryDate']['startDate'])
    data['data']['items'][0]['deliveryDate']['endDate'] = adapt_delivery_date(data['data']['items'][0]['deliveryDate']['endDate'])
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


def capitalize_first_letter(string):
    string = string.capitalize()
    return string


def get_unit_name(name):
    return {
        u'штуки': u'\tшт.\t',
        u'упаковка': u'\tупак.\t',
        u'набір': u'\tнаб.\t',
        u'кілограми': u'\tкг.\t',
        u'лот': u'\tлот\t',
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
        u'Відхилено': 'cancelled'
    }
    status_resolved = {
        u'Розглянуто': 'resolved',
        u'Вирішена': 'resolved'
    }
    pending_status = {
        u'Обробляється': 'pending'
    }
    if u'підтвердити задоволення вимоги' in test_name or 'resolved' in test_name:
        value = status_resolved[claim_status]
    elif u"Відображення статусу 'pending'" in test_name:
        value = pending_status[claim_status]
    else:
        value = status[claim_status]
    return value


def get_resolution_type(resolution):
    types = {
        u'Вирішено': 'resolved'
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
    if type_complaint == 'tender':
        value = tender_uaid + '.1'
    elif type_complaint == 'lot':
        value = tender_uaid + '.2'
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

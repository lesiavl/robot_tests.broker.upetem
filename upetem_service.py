# -*- coding: utf-8 -
from iso8601 import parse_date
from datetime import datetime
from robot.libraries.BuiltIn import BuiltIn
from robot.output import librarylogger

def get_library():
    return BuiltIn().get_library_instance('Selenium2Library')


def get_webdriver_instance():
    return get_library()._current_browser()


def convert_datetime_for_delivery(isodate):
    iso_dt = parse_date(isodate)
    date_string = iso_dt.strftime("%Y-%m-%d %H:%M")
    return date_string


def convert_date_for_compare(datestr):
    return datetime.strptime(datestr, "%d.%m.%Y %H:%M").strftime("%Y-%m-%d %H:%M")


def procuring_entity_name(tender_data):
    tender_data.data.procuringEntity['name'] = u"4k Marina"
    return tender_data


def split_take_item(value, separator, index):
    librarylogger.console('split_take_item')
    librarylogger.console(value)
    librarylogger.console(separator)
    librarylogger.console(index)
    return value.split(separator)[int(index)]


def split_take_slice(value, separator, _from=None, to=None):
    librarylogger.console(value)
    librarylogger.console(separator)
    librarylogger.console(_from)
    librarylogger.console(to)
    l = value.split(separator)
    if to:
        l = l[:int(to)]
    if _from:
        l = l[int(_from):]
    return l

def split_take_slice_from(value, separator, _from):
    librarylogger.console('split_take_slice_from')
    return split_take_slice(value, separator, _from)

def split_take_slice_to(value, separator, to):
    librarylogger.console('split_take_slice_to')
    return split_take_slice(value, separator, to=to)

def join(l, separator):
    librarylogger.console('join')
    librarylogger.console(l)
    return separator.join(l)


def get_invisible_text(locator):
    element = get_library()._element_find(locator, False, True)
    text = get_webdriver_instance().execute_script('return jQuery(arguments[0]).text();', element)
    return text
    

def get_text_excluding_children(locator):
    element = get_library()._element_find(locator, False, True)
    text = get_webdriver_instance().execute_script("""
    return jQuery(arguments[0]).contents().filter(function() {
        return this.nodeType == Node.TEXT_NODE;
    }).text();
    """, element)
    return text.strip()
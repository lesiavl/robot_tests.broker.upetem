# coding=utf-8

def adapt_unit_name(data):
	return {
        u"наб.": u"набір",
        u"шт.": u"штуки",
        u"упак.": u"упаковка"
	}.get(data, data)
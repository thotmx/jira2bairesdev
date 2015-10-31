require 'roo-xls'

file = "/home/thot/Descargas/Hermes Ojeda - 19102015.xls"

def worked_hours(file)
  xls = Roo::Spreadsheet.open(file)
  sheet = xls.sheet("Worklogs")
  sheet.parse(date: /Work date/, hours: /Hours/, description: /Work Description/)
end


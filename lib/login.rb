require "watir-webdriver"
require 'roo-xls'
require "headless"

browser = Watir::Browser.new

credentials = YAML.load(File.read("config.yml"))
browser.goto "http://timetracker.bairesdev.com"

browser.text_field(id: "ctl00_ContentPlaceHolder_UserNameTextBox").set credentials["user"]
browser.text_field(id: "ctl00_ContentPlaceHolder_PasswordTextBox").set credentials["password"]

browser.button(id: "ctl00_ContentPlaceHolder_LoginButton").click

if browser.text.include? "Bienvenido(a)"
  puts "You're in!!!"
else
  puts "Sorry"
end

file = "/home/thot/Descargas/Hermes Ojeda - 26102015.xls"

def worked_hours(file)
  xls = Roo::Spreadsheet.open(file)
  sheet = xls.sheet("Worklogs")
  sheet.parse(date: /Work date/, hours: /Hours/, description: /Work Description/)
end

worked_hours(file).each do |report|
  next if report[:date].is_a? String
  next if report[:date].nil? 
  browser.link(text: "Nuevo registro").click
  browser.link(title: report[:date].strftime("%B %d")).click
  browser.select_list(id: "ctl00_ContentPlaceHolder_idProyectoDropDownList").select("iSeatz - iSeatz")
  browser.select_list(id: "ctl00_ContentPlaceHolder_idTipoAsignacionDropDownList").select("Software Development")
  browser.text_field(id: "ctl00_ContentPlaceHolder_TiempoTextBox").set report[:hours]
  browser.textarea(id: "ctl00_ContentPlaceHolder_DescripcionTextBox").set report[:description]
  browser.button(id: "ctl00_ContentPlaceHolder_btnAceptar").click
end

browser.close

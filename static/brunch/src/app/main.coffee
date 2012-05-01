window.app = {}
app.routers = {}
app.models = {}
app.collections = {}
app.views = {}
app.hxl = {}


MainRouter = require('routers/main_router').MainRouter
HomeView = require('views/home_view').HomeView
UploadView = require('views/upload_view').UploadView
WorksheetView = require('views/worksheet_view').WorksheetView

# app bootstrapping on document ready
$(document).ready ->
  app.initialize = ->
    app.routers.main = new MainRouter()
    app.views.home = new HomeView()
    app.views.upload = new UploadView()
    app.views.worksheet = new WorksheetView()
    app.hxl.hxltypes ={displaced:{attributes:["hhCount","personCount","origin","location","source","datadate"],children:["idp","refugee","others"]},distribution : {attributes:["blanketsProvided","bucketsProvided","cotsProvided","familyTentsProvided","jerryCansProvided","kitchenSetsProvided","largeTentsProvided","matsProvided","mosquitoNetsProvided","nonFoodItemsProvided","ropeProvided","sheetsProvided","tarpaulinProvided","tentsProvided","waterFiltersProvided","toolKitsProvided","cgiProvided","hygieneKitsProvided","blanketsProvided","groundSheetsProvided","hhCount","personCount","activityDescription","activityTitle","actualEnd","actualStart","atLocation","hasStatus","implementedBy"]}}
    app.hxl.hxllabels = {displaced:"Displaced People",hhCount:"Number of Households",personCount:"Number of People",source:"Data Source",origin:"Location of Origin",location:"Current Location",datadate:"Date of the Data",idp:"Internally Displaced",refugee:"Refugees and Asylum Seekers",others:"Others of Concern",blanketsProvided:"Blankets Provided",bucketsProvided:"Buckets Provided",cotsProvided:"Cots Provided",familyTentsProvided:"Family Tents Provided",jerryCansProvided:"Jerry Cans Provided",cgiProvided:"CGI Provided",kitchenSetsProvided:"Kitchen Sets Provided",largeTentsProvided:"Large Tents Provided",matsProvided:"Sleeping Mats Provided",mosquitoNetsProvided:"Mosquito Nets Provided",nonFoodItemsProvided:"Non-Food Items Provided",ropeProvided:"Rope Provided (m)",sheetsProvided:"Sheets Provided",tarpaulinProvided:"Tarpaulins Provided",tentsProvided:"Tents Provided",waterFiltersProvided:"Water Filters Provided",toolKitsProvided:"Tool Kits Provided",hygieneKitsProvided:"Hygiene Kits Provided",blanketsProvided:"Blankets Provided",groundSheetsProvided:"Ground Sheets Provided",hhCount:"Households reached",personCount:"Persons reached",activityDescription:"Activity Description",activityTitle:"Activity Title",actualEnd:"Actual End Date",actualStart:"Actual Start Date",atLocation:"Location",hasStatus:"Status of the Activity",implementedBy:"Implementing Organization",distribution:"Distribution"}
    app.routers.main.navigate 'home', true if Backbone.history.getFragment() is ''
  app.initialize()
  Backbone.history.start()

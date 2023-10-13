/*
*@author        Juanjo Ramos Sastre
*@description   apex class that handles the logic needed to create a new flight from the related WLC (FlightCalculator)
*
*@created 13/10/2023
*/

public without sharing class FlightDistanceCalculator {
    //Global variables of the class
    Airport__c arrivalAirport = new Airport__c();
    Airport__c departureAirport = new Airport__c();
    list<Airport__c> airportList = new list<Airport__c>();

    //--------------------------------------------------------------------------------------------------------
    //@description  function to create a new flight between 2 airports
    //@param        air1    =>  Departura airport in the new flight
    //@param        air2    =>  Arrival airport in the new flight
    //@return       VOID
    //--------------------------------------------------------------------------------------------------------
    @AuraEnabled
    public static void saveFlight(Airport__c air1, Airport__c air2) {
        //Calculus of the distance between air1 and air2
        Decimal r = 6371; // Radius of the Earth in kilometers
        Decimal dLat = (air2.Latitude__c - air1.Latitude__c);
        Decimal dLon = (air2.Longitude__c - air1.Longitude__c);
        Decimal a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                    Math.cos(air1.Latitude__c) * Math.cos(air2.Latitude__c) *
                    Math.sin(dLon / 2) * Math.sin(dLon / 2);
        Decimal c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        Decimal distance = r * c;

        //create newFlight variable to insert and add the flight data.
        flight__c newFlight = new flight__c();
        newFlight.Departure_Airport__c = air1.id;
        newFlight.Arrival_Airport__c = air2.id;
        newFlight.Distance__c = distance;
        newFlight.name = air1.name + '-' +air2.name;

        //manage the insert of the new flight
        try{
            insert newFlight;
        } catch(DmlException e) {
            for(Integer index = 0; index < e.getNumDml(); index++) {
              System.debug('Flight '+ e.getDmlIndex(index) + ' failed to save.');
              System.debug('The error was '+e.getDmlMessage(index));
              System.debug('The error type was '+ e.getDmlType(index));
            }
        }
    }

    //--------------------------------------------------------------------------------------------------------
    //@description  Function to get all the airports that are active at the moment for us to create a new flight
    //@return       airportList
    //--------------------------------------------------------------------------------------------------------
    @AuraEnabled(cacheable=true)
    public static list<airport__c> getAirportList(){
        list<airport__c> airportList = new list<airport__c>();
        return airportList = [Select id, name, IATA_Code__c, Latitude__c, Longitude__c From Airport__c Where isActive__c = true];
    }
}
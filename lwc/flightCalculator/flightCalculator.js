/*
*@author        Juanjo Ramos Sastre
*@description   JS class that handles the visual interaction and events needed to create a new flight
*
*@created 13/10/2023
*/

//IMPORTS
//--------------------------------------------------------------------------------------------------------
import { LightningElement, track, api, wire } from 'lwc';
import saveFlight from '@salesforce/apex/FlightDistanceCalculator.saveFlight';
import getAirportList from '@salesforce/apex/FlightDistanceCalculator.getAirportList';
//--------------------------------------------------------------------------------------------------------

export default class FlightDistanceCalculator extends LightningElement {
    @api airports = [];         // List of available airports
    @track departureAirport;    // Departure Airport selected
    @track arrivalAirport;      // Arrival Airport selected

    //--------------------------------------------------------------------------------------------------------
    //@description  function to get the lists of available airpots from the apex class
    //@salesforce/apex/FlightDistanceCalculator.getAirportList
    //--------------------------------------------------------------------------------------------------------
    @wire(getAirportList)
    wiredAirports({ data, error }) {
        if (data) {
            this.airports = data.map(airport => ({
                label: airport.Name + ' - ' + airport.IATA_Code__c,
                value: airport.Id
            }));
        } else if (error) {
            // Handle any errors
            console.error(error);
        }
    }

    handleDepartureChange(event) {
        this.departureAirport = event.detail.value;
    }

    handleArrivalChange(event) {
        this.arrivalAirport = event.detail.value;
    }

    //--------------------------------------------------------------------------------------------------------
    //@description  function to save the new flight selected by the user
    //@salesforce/apex/FlightDistanceCalculator.saveFlight
    //--------------------------------------------------------------------------------------------------------
    handleSaveFlight() {
        console.log('START => handleSaveFlight');
        const departureAirportData = this.airports.find(airport => airport.value === this.departureAirport);
        const arrivalAirportData = this.airports.find(airport => airport.value === this.arrivalAirport);
        if (this.departureAirportData && this.arrivalAirportData) {
            // Call the Apex method to calculate the distance and save the flight in DB
            saveFlight({ 
                air1: departureAirportData,
                air2: arrivalAirportData
            })
            .then(result => {
                // Handle successful save
                console.log('Flight saved:', result);
            })
            .catch(error => {
                // Handle any errors
                console.error(error);
            });
        }
    }
}
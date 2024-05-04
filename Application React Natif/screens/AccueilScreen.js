import React, { Component } from 'react'
import { Button, View, Text } from 'react-native'
import { useRoute } from '@react-navigation/native'
import Reservation from '../components/Reservation'

import { useState, useEffect } from 'react'

export default function AccueilScreen() {
  const route = useRoute()
  const id = route.params?.id
  const link = 'http://192.168.56.1/api/reservation.php?idClient='
  const [reservationData, setReservationData] = useState([])
  const [isLoading, setLoading] = useState(true)

  useEffect(() => {
    console.log('on va chercher les données sur ' + link+id)
    fetch(link + id)
      .then(function (response) {
        console.log('traitement réponse')
        console.log(response)
        return response.json()
      })
      .then(
        function (data) {
          console.log('traitement données')
          setReservationData(data)
          setLoading(false)
        },
        function (error) {
          console.log(error)
        }
      )
  }, [])

  if (isLoading) {
    return (
      <View>
        <Text>EN CHARGEMENT de Accueil</Text>
      </View>
    )
  } else {

// il faut verifier s'il y a un message
if(reservationData.hasOwnProperty("message")){
  return (<View><Text>Une erreur est survenue :{reservationData.message}</Text></View>)
} else {
  return (
    <View>
      <Text>AccueilScreen</Text>
      {reservationData.map((uneReservation, index) => (
        <Reservation
          key={index}
          idReservation={uneReservation.id}
          datedeb={uneReservation.dateDebut}
          datefin={uneReservation.dateFin}
          logement={uneReservation.Logement}
          client={id}
        />
      ))}
    </View>
  )
}
}

   
}

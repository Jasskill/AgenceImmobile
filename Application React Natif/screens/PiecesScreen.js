import React, { Component } from 'react'
import { Button, View, Text } from 'react-native'
import { useRoute } from '@react-navigation/native'
import Reservation from '../components/Reservation'
import { useState, useEffect } from 'react'
export default function PiecesScreen() {
  const route = useRoute()
  const id = route.params?.idReservation
  const link = 'http://192.168.1.30/api/piece.php?idReservation='
  const [lesPieces, setLesPieces] = useState({})
  const [isLoading, setLoading] = useState(true)

  useEffect(() => {
    console.log(link + id)
    fetch(link + id)
      .then(function (response) {
        console.log('traitement réponse')
        console.log(response)
        return response.json()
      })
      .then(
        function (data) {
          console.log('traitement données')
          setLesPieces(data)
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
        <Text>EN CHARGEMENT</Text>
      </View>
    )
  } else {
    return (
      <View>
        <Text>PiecesScreen</Text>
        {/* {lesPieces.map((unePiece, index) => (
          <Reservation
            key={index}
            idReservation={uneReservation.id}
            datedeb={uneReservation.dateDebut}
            datefin={uneReservation.dateFin}
            logement={uneReservation.Logement}
          />
        ))} */}
      </View>
    )
  }
}

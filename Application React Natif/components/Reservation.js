import { Button, View, Text, StyleSheet } from 'react-native'
import React, { Component } from 'react'
import { useNavigation } from '@react-navigation/native'
export default function Reservation(props) {
  const navigation = useNavigation()
  return (
    <View style={style.reservationContainer}>
      <Text style={style.textDescription}>{props.logement.description}</Text>
      <Text style={style.textBase}>
        {props.logement.rue}, {props.logement.codePostal}
      </Text>
      <Text style={style.textDate}>
        Du {props.datedeb} au {props.datefin}
      </Text>
      <Button
        onPress={() => {
          navigation.navigate('PiecesScreen', {
            idReservation: props.idReservation,
          })
        }}
        title="Voir"
      />
    </View>
  )
}

const style = StyleSheet.create({
  reservationContainer: {
    backgroundColor: '#555',
    margin: 20,
  },
  textDescription: { fontSize: 20, fontWeight: 'bold', textAlign: 'center' },
  textDate: { fontStyle: 'italic', textAlign: 'center' },
  textBase: { textAlign: 'center' },
})

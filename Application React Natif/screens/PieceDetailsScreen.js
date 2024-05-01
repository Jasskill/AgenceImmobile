import React, { Component, TouchableOpacity } from 'react'
import { Button, View, Text, StyleSheet, TextInput,ScrollView, Alert } from 'react-native'
import { useNavigation } from '@react-navigation/native'
import { useRoute } from '@react-navigation/native'
import RNPickerSelect from 'react-native-picker-select';
import { useState, useEffect } from 'react'
import Equipement from '../components/Equipement';
import TakePhoto from '../components/TakePhoto';
export default function PieceDetailsScreen() {
    const options = [
        { label: '1⭐', value: '1' },
        { label: '2⭐⭐', value: '2' },
        { label: '3⭐⭐⭐', value: '3' },
        { label: '4⭐⭐⭐⭐', value: '4' },
        { label: '5⭐⭐⭐⭐⭐', value: '5' },
      ];
  const navigation = useNavigation()
  const route = useRoute()
  const props = route.params?.props
  const [commentaire, onChangeCommentaire] = React.useState('');
  const [selectedValue, setSelectedValue] = useState(5);
  console.log(props)
  const styles = StyleSheet.create({
    input: {
      height: 40,
      margin: 12,
      borderWidth: 1,
      padding: 10,
    },
  });
  return (
    <ScrollView >
      <Text style={{alignItems: 'center' }}>PieceDetailsScreen pour la pièce : {props.infos.id}</Text>
      <Text> Ancien commentaire : {props.infos.hasOwnProperty("ancienCommentaire") ? props.infos.ancienCommentaire : "Soyez le premier à commenter !" }</Text>
      <Text> Ancienne note : {props.infos.hasOwnProperty("ancienneNote")  ? props.infos.ancienneNote : "Soyez le premier à noter !" }</Text>
      <TextInput
       style={styles.input}

        onChangeText={onChangeCommentaire}
        value={commentaire}
        placeholder="Votre beau commentaire"
      />
      <RNPickerSelect
        items={options}
        onValueChange={(value) => setSelectedValue(value)}
        value={selectedValue}
      />
      <Text>Prendre photo</Text>
      <TakePhoto/>
      <Button
        onPress={() => {
          console.log('SKIPPED CONNECTION')
          if(commentaire!=''){
            //on balance la sauce
            navigation.navigate('AccueilScreen', { id: 6 })
          } else {
            //toast
            Alert.alert('🛑Attention🛑', 'Merci de remplir correctement chaque champ avant de valider !')
          }
          
        }}
        title="Valider"
      />
      <Text>Les équipements de la pièce :</Text>
       { 
      props.equipements.map((unEquipement, index) => (
        <Equipement
          key={index}
          infos={unEquipement}
        />
      )) }
    </ScrollView>
  )

 
}
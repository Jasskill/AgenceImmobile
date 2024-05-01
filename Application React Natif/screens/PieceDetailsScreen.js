import React, { Component, TouchableOpacity } from 'react'
import { Button, View, Text, StyleSheet, TextInput,ScrollView, Alert } from 'react-native'
import { useNavigation } from '@react-navigation/native'
import { useRoute } from '@react-navigation/native'
import RNPickerSelect from 'react-native-picker-select';
import { useState, useEffect } from 'react'
import Equipement from '../components/Equipement';

import * as ImagePicker from 'expo-image-picker';
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
  const lesImages = []
  const [count, setCount]= useState(0)
  const [commentaire, onChangeCommentaire] = useState('');
  const [selectedValue, setSelectedValue] = useState(5);
  console.log(props)
  const styles = StyleSheet.create({
    input: {
      height: 40,
      margin: 12,
      borderWidth: 1,
      padding: 10,
    },image: {
      width: 200,
      height: 200,
    },
  });


  const [image, setImage] = useState(null);
  const pickImage = async () => {
    // No permissions request is necessary for launching the image library
    let result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      allowsEditing: true,
      aspect: [4, 3],
      quality: 1,
    });

    if (!result.canceled) {
      lesImages.push(result.assets[0].uri)
      console.log(lesImages.length , lesImages)
      setCount( lesImages.length)
    }
  };

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
      
      <Button title="Pick an image from camera roll" onPress={pickImage} />
      {<Text>Vous avez séléctionné {count} image </Text> }

      <Button
        onPress={() => {
          if(commentaire!='' && count!=0){
            //on balance la sauce

            navigation.navigate('AccueilScreen', { id: 6 })
          } else {
            //toast
            Alert.alert('🛑Attention🛑', 'Merci de remplir correctement chaque champ et de prendre des photos avant de valider !')
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
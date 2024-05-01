import { useNavigation } from '@react-navigation/native'
import React from 'react';
import { StyleSheet } from 'react-native';
import { Button, View, Text } from 'react-native'
import Photo from './Photo';
export default function Equipement(props) {
    const navigation = useNavigation()
    return (<View><Text>{props.infos.libelle}</Text>
    {props.infos.listePhoto.map((unePhoto, index) => (
        <Photo
          key={index}
          lien={unePhoto}
        />
      )) }
    </View>)
}
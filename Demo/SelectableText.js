import React from 'react'
import {Text, requireNativeComponent} from 'react-native';

const RNSelectableText = requireNativeComponent('RNSelectableText');

export const SelectableText = ({ onSelection, ...props }) => {
  const onSelectionNative = ({ nativeEvent: { content, eventType } })  => {
    onSelection && onSelection({ content, eventType })
  }

  return (
    <RNSelectableText {...props} onSelection={onSelectionNative} />
  )
}

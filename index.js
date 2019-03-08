import {requireNativeComponent} from 'react-native';

const { RNSelectableText } = requireNativeComponent('RNSelectableText');

export const SelectableText = ({ ...props, onSelection }, forwardedRef) => {
  const onSelectionNative = ({ nativeEvent: { content, eventType } })  => {
    onSelection({ content, eventType })
  }

  return (
    <RNSelectableText {...props} ref={forwardedRef} onSelection={onSelectionNative} />
  )
}

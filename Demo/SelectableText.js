import React from "react";
import { Text, requireNativeComponent } from "react-native";

const RNSelectableText = requireNativeComponent("RNSelectableText");

export const SelectableText = ({ onSelection, ...props }) => {
  const onSelectionNative = ({
    nativeEvent: { content, eventType, selectionStart, selectionEnd }
  }) => {
    onSelection &&
      onSelection({ content, eventType, selectionStart, selectionEnd });
  };

  return <RNSelectableText {...props} onSelection={onSelectionNative} />;
};

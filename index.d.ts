import React, { ReactNode } from "react";
import { StyleProp, TextStyle, TextProps } from "react-native";

export interface SelectableTextProps {
  value?: string;
  onSelection?: (args: {
    eventType: string;
    content: string;
    selectionStart: number;
    selectionEnd: number;
  }) => void;

  menuItems?: string[];
  highlights?: Array<{ id: string; start: number; end: number }>;
  highlightColor?: string;
  style?: StyleProp<TextStyle>;
  highlightedTextStyle?: StyleProp<TextStyle>;
  onHighlightPress?: (id: string) => void;
  appendToChildren?: ReactNode;
  TextComponent?: ReactNode;
  textValueProp?: string;
  textComponentProps?: TextProps;
}

export class SelectableText extends React.Component<SelectableTextProps> {}

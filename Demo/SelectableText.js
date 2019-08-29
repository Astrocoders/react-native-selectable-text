import React from 'react'
import { Text, requireNativeComponent, Platform } from 'react-native'
import { v4 } from 'uuid'
import memoize from 'fast-memoize'

const RNSelectableText = requireNativeComponent('RNSelectableText')

/**
 * Props
 * ...TextProps
 * onSelection: ({ content: string, eventType: string, selectionStart: int, selectionEnd: int }) => void
 * children: ReactNode
 * highlights: array({ id, start, end })
 * highlightColor: string
 * strikenTextStyle: ReactNativeStyle
 * content: array({ text: string, isStrike: boolean, isHighlight: boolean })
 */
export class SelectableText extends React.PureComponent {
  constructor(props) {
    super(props)

    this.ref = React.createRef()
  }

  onSelectionNative = ({ nativeEvent: { content, eventType, selectionStart, selectionEnd, highlightId }}) => {
    if (this.props.onSelection) {
      this.props.onSelection({
        content,
        eventType,
        selectionStart,
        selectionEnd,
        highlightId,
      })
    }
  }

  render() {
    const { onSelection, onHighlightPress, value, strikenTextStyle, children, ...props } = this.props

    return (
      <RNSelectableText
        {...props}
        selectable
        onSelection={this.onSelectionNative}
        highlights={props.highlights || []}
        ref={this.ref}
      >
        {value.map(({ id, isHighlight, text, isStrike }) => {
          const strikeStyle = isStrike ? strikenTextStyle : {}
          const highlightStyle = isHighlight ? { backgroundColor: props.highlightColor } : {}
            return (
              <Text
                key={v4()}
                selectable
                style={
                  {
                    ...strikeStyle,
                    ...highlightStyle,
                  }
                }
              >
                {text}
              </Text>
            )
          })}
        {props.appendToChildren ? props.appendToChildren : null}
      </RNSelectableText>
    )
  }
}

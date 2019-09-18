import React from 'react'
import { Text, requireNativeComponent, Platform } from 'react-native'
import { v4 } from 'uuid'
import * as R from 'ramda'
import memoize from 'fast-memoize'

const RNSelectableText = requireNativeComponent('RNSelectableText')

/**
 * Props
 * ...TextProps
 * onSelection: ({ content: string, eventType: string, selectionStart: int, selectionEnd: int }) => void
 * children: ReactNode
 * highlights: array({ id, start, end })
 * highlightColor: string
 */
export class SelectableText extends React.PureComponent {
  constructor(props) {
    super(props)

    this.ref = React.createRef()
  }

  onSelectionNative = ({
    nativeEvent: { content, eventType, selectionStart, selectionEnd, highlightId },
  }) => {
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
        {R.compose(
          R.map(({ id, highlight, text, isStrike }) => {
            const strikeStyle = isStrike ? strikenTextStyle : {}
            const highlightStyle = { backgroundColor: props.highlightColor, ...strikeStyle }

            const hasHighlights = Array.isArray(highlight) && highlight.length > 0

            if(!hasHighlights) {
              return (
                <Text
                  key={v4()}
                  selectable
                  style={
                    strikeStyle
                  }
                >
                  {text}
                </Text>
              )
            }

            const highlightsMapped = highlight.sort((a, b) => a.start - b.start).map((item) =>
              ({
                text: text.slice(item.start, item.end + 1),
                init: item.start,
                end: item.end,
                isHighlight: true,
              })
            )

            const notHighlightedTexts = highlightsMapped[0].init === 0  && highlightsMapped[0].end === text.length ? [] : highlightsMapped.reduce((acc, item, index, array) => {
              const init = index === 0 && item.init !== 0 ?  0 : item.end + 1
              const end = index < highlightsMapped.length - 1 && index > 0 ? array[index + 1].init - 1 : index === 0 && array.length > 1 ? array[index + 1].init - 1 : index === 0 && index === array.length - 1 && init === 0 ? item.init - 1 : text.length - 1

              if (index == highlightsMapped.length - 1 && end < text.length - 1) {
                const initLastElement = item.end + 1
                const endLastElement = text.length

                return [ ...acc,
                  {
                    text: text.slice(init, end + 1),
                    init,
                    end,
                    isHighlight: false,
                  },
                  {
                    text: text.slice(initLastElement, endLastElement),
                    init: initLastElement,
                    end: endLastElement,
                    isHighlight: false,
                  } ]
              }

              return text.slice(init, end + 1).length > 0 ? [ ...acc, {
                text: text.slice(init, end + 1),
                init,
                end,
                isHighlight: false,
              } ] : acc
            }, [])

            return highlightsMapped.concat(notHighlightedTexts).sort((a, b) => a.init - b.init).map(item => (
              <Text
                key={v4()}
                selectable
                style={
                  item.isHighlight ? highlightStyle : strikeStyle
                }
              >
                {item.text}
              </Text>
            ))
          }),
          R.flatten,
        )(value)}
        {props.appendToChildren ? props.appendToChildren : null}
      </RNSelectableText>
    )
  }
}

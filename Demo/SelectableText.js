import React from 'react'
import { Text, requireNativeComponent, Platform } from 'react-native'
import { v4 } from 'uuid'
import memoize from 'fast-memoize'

const RNSelectableText = requireNativeComponent('RNSelectableText')

/**
 * numbers: array({start: int, end: int, id: string, highlightColor: string})
 */
const combineHighlights = memoize(numbers => {
  return numbers
    .sort((a, b) => a.start - b.start || a.end - b.end)
    .reduce(function(combined, next) {
      if (!combined.length || combined[combined.length - 1].end < next.start) combined.push(next)
      else {
        var prev = combined.pop()
        combined.push({
          start: prev.start,
          end: Math.max(prev.end, next.end),
          id: next.id,
          highlightColor: prev.highlightColor
        })
      }
      return combined
    }, [])
})

/**
 * value: string
 * highlights: array({start: int, end: int, id: any, highlightColor: string})
 */
const mapHighlightsRanges = (value, highlights) => {
  const combinedHighlights = combineHighlights(highlights)

  if (combinedHighlights.length === 0) return [{ isHighlight: false, text: value }]

  const data = [{ isHighlight: false, text: value.slice(0, combinedHighlights[0].start) }]

  combinedHighlights.forEach(({ start, end, highlightColor }, idx) => {
    data.push({
      isHighlight: true,
      text: value.slice(start, end),
      highlightColor: highlightColor,
    })

    if (combinedHighlights[idx + 1]) {
      data.push({
        isHighlight: false,
        text: value.slice(end, combinedHighlights[idx + 1].start),
        highlightColor: '',
      })
    }
  })

  data.push({
    isHighlight: false,
    text: value.slice(combinedHighlights[combinedHighlights.length - 1].end, value.length),
    highlightColor: '',
  })

  return data.filter(x => x.text)
}

/**
 * Props
 * ...TextProps
 * onSelection: ({ content: string, eventType: string, selectionStart: int, selectionEnd: int }) => void
 * children: ReactNode
 * highlights: array({ id, start, end })
 * highlightColor: string
 * onHighlightPress: string => void
 * textValueProp: string
 * TextComponent: ReactNode
 * textComponentProps: object
 */
export const SelectableText = ({
  onSelection, onHighlightPress, textValueProp, value, TextComponent,
  textComponentProps, ...props
}) => {
  const usesTextComponent = !TextComponent;
  TextComponent = TextComponent || Text;
  textValueProp = textValueProp || 'children';  // default to `children` which will render `value` as a child of `TextComponent`
  const onSelectionNative = ({
    nativeEvent: { content, eventType, selectionStart, selectionEnd },
  }) => {
    onSelection && onSelection({ content, eventType, selectionStart, selectionEnd })
  }

  const onHighlightPressNative = onHighlightPress
    ? Platform.OS === 'ios'
      ? ({ nativeEvent: { clickedRangeStart, clickedRangeEnd } }) => {
          if (!props.highlights || props.highlights.length === 0) return

          const mergedHighlights = combineHighlights(props.highlights)

          const hightlightInRange = mergedHighlights.find(
            ({ start, end }) => clickedRangeStart >= start - 1 && clickedRangeEnd <= end + 1,
          )

          if (hightlightInRange) {
            onHighlightPress(hightlightInRange.id)
          }
        }
      : onHighlightPress
    : () => {}

  // highlights feature is only supported if `TextComponent == Text`
  let textValue = value;
  if (usesTextComponent) {
    textValue = (
      props.highlights && props.highlights.length > 0
        ? mapHighlightsRanges(value, props.highlights).map(({ id, isHighlight, text, highlightColor }) => (
            <Text
              key={v4()}
              selectable
              style={
                isHighlight
                  ? {
                      backgroundColor: highlightColor != '' ? highlightColor : props.highlightColor,
                    }
                  : {}
              }
              onPress={() => {
                if (isHighlight) {
                  onHighlightPress && onHighlightPress(id)
                }
              }}
            >
              {text}
            </Text>
          ))
      : [value]
    );
    if (props.appendToChildren) {
      textValue.push(props.appendToChildren);
    }
  }
  return (
    <RNSelectableText
      {...props}
      onHighlightPress={onHighlightPressNative}
      selectable
      onSelection={onSelectionNative}
    >
      <TextComponent
        key={v4()}
        {...{[textValueProp]: textValue, ...textComponentProps}}
      />
    </RNSelectableText>
  )
}

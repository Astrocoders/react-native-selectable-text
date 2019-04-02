import React from 'react'
import { Text, requireNativeComponent } from 'react-native'
import { v4 } from 'uuid'
import memoize from 'fast-memoize'

const RNSelectableText = requireNativeComponent('RNSelectableText')

/**
 * numbers: array({start: int, end: int, id: string})
 */
const combineHighlights = memoize(numbers => {
  return numbers
    .sort((a, b) => a.start - b.start || a.end - b.end)
    .reduce(function(combined, next) {
      if (!combined.length || combined[combined.length - 1].end < next.start)
        combined.push(next)
      else {
        var prev = combined.pop()
        combined.push({
          start: prev.start,
          end: Math.max(prev.end, next.end),
          id: next.id,
        })
      }
      return combined
    }, [])
})

/**
 * value: string
 * highlights: array({start: int, end: int, id: any})
 */
const mapHighlightsRanges = memoize((value, highlights) => {
  const combinedHighlights = combineHighlights(highlights)

  if (combinedHighlights.length === 0)
    return [{ isHighlight: false, text: value }]

  const data = [
    { isHighlight: false, text: value.slice(0, combinedHighlights[0].start) },
  ]

  combinedHighlights.forEach(({ start, end }, idx) => {
    data.push({
      isHighlight: true,
      text: value.slice(start, end),
    })

    if (combinedHighlights[idx + 1]) {
      data.push({
        isHighlight: false,
        text: value.slice(end, combinedHighlights[idx + 1].start),
      })
    }
  })

  data.push({
    isHighlight: false,
    text: value.slice(
      combinedHighlights[combinedHighlights.length - 1].end,
      value.length
    ),
  })

  return data.filter(x => x.text)
})

/**
 * Props
 * ...TextProps
 * onSelection: ({ content: string, eventType: string, selectionStart: int, selectionEnd: int }) => void
 * children: ReactNode
 * highlights: array({ id, start, end })
 * highlightColor: string
 * onHighlightPress: string => void
 */
export const SelectableText = ({ onSelection, value, children, ...props }) => {
  const onSelectionNative = ({
    nativeEvent: { content, eventType, selectionStart, selectionEnd },
  }) => {
    onSelection &&
      onSelection({ content, eventType, selectionStart, selectionEnd })
  }

  return (
    <RNSelectableText {...props} selectable onSelection={onSelectionNative}>
      <Text selectable key={v4()}>
        {props.highlights && props.highlights.length > 0
          ? mapHighlightsRanges(value, props.highlights).map(
              ({ id, isHighlight, text }) => (
                <Text
                  key={v4()}
                  selectable
                  style={
                    isHighlight ? { backgroundColor: props.highlightColor } : {}
                  }
                  onPress={() =>
                    isHighlight &&
                    props.onHighlightPress &&
                    props.onHighlightPress(id)
                  }
                >
                  {text}{' '}
                </Text>
              )
            )
          : value}
      </Text>
    </RNSelectableText>
  )
}

import React from 'react'
import { Text, requireNativeComponent, Platform } from 'react-native'
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
      if (!combined.length || combined[combined.length - 1].end < next.start) combined.push(next)
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
const mapHighlightsRanges = (value, highlights) => {
  const combinedHighlights = combineHighlights(highlights)

  if (combinedHighlights.length === 0) return [{ isHighlight: false, text: value }]

  const data = [{ isHighlight: false, text: value.slice(0, combinedHighlights[0].start) }]

  combinedHighlights.forEach(({ id, start, end }, idx) => {
    data.push({
      id,
      isHighlight: true,
      text: value.slice(start, end),
    })

    if (combinedHighlights[idx + 1]) {
      data.push({
        id: combinedHighlights[idx + 1].id,
        isHighlight: false,
        text: value.slice(end, combinedHighlights[idx + 1].start),
      })
    }
  })

  data.push({
    id: combinedHighlights[combinedHighlights.length - 1].id,
    isHighlight: false,
    text: value.slice(combinedHighlights[combinedHighlights.length - 1].end, value.length),
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
    const { onSelection, onHighlightPress, value, children, ...props } = this.props

    return (
      <RNSelectableText
        {...props}
        selectable
        onSelection={this.onSelectionNative}
        highlights={props.highlights || []}
        ref={this.ref}
      >
        <Text selectable key={v4()}>
          {props.highlights && props.highlights.length > 0
            ? mapHighlightsRanges(value, props.highlights).map(({ id, isHighlight, text }) => (
                <Text
                  key={v4()}
                  selectable
                  style={
                    isHighlight
                      ? {
                          backgroundColor: props.highlightColor,
                        }
                      : {}
                  }
                >
                  {text}
                </Text>
              ))
            : value}
          {props.appendToChildren ? props.appendToChildren : null}
        </Text>
      </RNSelectableText>
    )
  }
}

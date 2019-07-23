package com.astrocoders.selectabletext;

import android.graphics.Rect;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.ActionMode;
import android.view.ActionMode.Callback;
import android.view.MotionEvent;
import android.text.Spannable;
import android.widget.TextView;
import android.view.View;

import java.util.Map;

import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.events.RCTEventEmitter;

import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.views.text.ReactTextView;
import com.facebook.react.views.text.ReactTextViewManager;
import com.facebook.react.views.text.ReactTextUpdate;

import java.util.List;
import java.util.ArrayList;


public class RNSelectableTextManager extends ReactTextViewManager {
    public static final String REACT_CLASS = "RNSelectableText";
    private String clickedHighlightId = "";
    private ActionMode mActionMode;
    private ReadableArray menuItems;
    private ReadableArray highlights;

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @Override
    public ReactTextView createViewInstance(ThemedReactContext context) {
        ReactTextView view = new ReactTextView(context) {
            private Spannable mSpanned;

            @Override
            public void setText(ReactTextUpdate update) {
                this.mSpanned = update.getText();
                super.setText(update);
            }

            @Override
            public Spannable getSpanned() {
                return this.mSpanned;
            }

            @Override
            public void onAttachedToWindow() {
                if (this.isEnabled()) {
                    this.setEnabled(false);
                    this.setEnabled(true);
                }
                super.onAttachedToWindow();
            }

            @Override
            protected void onFocusChanged(boolean focused, int direction, Rect previouslyFocusedRect) {
                if (mActionMode != null) {
                    mActionMode.finish();
                }
                super.onFocusChanged(focused, direction, previouslyFocusedRect);
            }
        };

        return view;
    }


    @ReactProp(name = "menuItems")
    public void setMenuItems(ReactTextView textView, ReadableArray items) {
        this.menuItems = items;
        List<String> result = new ArrayList<String>(items.size());
        for (int i = 0; i < items.size(); i++) {
            result.add(items.getString(i));
        }

        registerSelectionListener(result.toArray(new String[items.size()]), textView);
    }

    @ReactProp(name = "highlights")
    public void setHighlights(ReactTextView textView, ReadableArray items) {
        this.highlights = items;
        registerTouchListener(items, textView);
    }

    public void registerTouchListener(final ReadableArray highlights, final ReactTextView view) {
        view.setOnTouchListener(new TextView.OnTouchListener() {
            @Override
            public boolean onTouch(View tv, MotionEvent event) {
                final ReactTextView textView = (ReactTextView) tv;

                float x = event.getX();
                float y = event.getY();

                if (event.getAction() ==  MotionEvent.ACTION_DOWN) {
                    if (mActionMode != null) {
                        mActionMode.finish();
                    }
                    int offset = textView.getOffsetForPosition(x, y);

                    Log.d("TOUCH",  String.valueOf(offset));
                    for (int i = 0; i < highlights.size(); i++) {
                        final ReadableMap currentItem = highlights.getMap(i);
                        if (offset >= currentItem.getInt("start") && offset <= currentItem.getInt("end")) {
                            clickedHighlightId = currentItem.getString("id");
                            Log.d("HIGHLIGHT ID", clickedHighlightId);
                            textView.startActionMode(new Callback() {
                                @Override
                                public boolean onCreateActionMode(ActionMode mode, Menu menu) {
                                    mActionMode = mode;

                                    return true;
                                }

                                @Override
                                public boolean onPrepareActionMode(ActionMode mode, Menu menu) {
                                    mActionMode = mode;

                                    menu.add(0, 0, 0, "Desmarcar");

                                    for (int i = 1; i < menuItems.size(); i++) {
                                        menu.add(0, i, 0, menuItems.getString(i));
                                    }

                                    return true;
                                }

                                @Override
                                public boolean onActionItemClicked(ActionMode mode, MenuItem item) {
                                    int selectionStart = currentItem.getInt("start");
                                    int selectionEnd = currentItem.getInt("end");
                                    String selectedText = textView.getText().toString().substring(selectionStart, selectionEnd);
                                    String eventType = menuItems.getString(item.getItemId());

                                    // Dispatch event
                                    onSelectNativeEvent(view, eventType.equals("Marcar") ? "Desmarcar" : eventType, selectedText, selectionStart, selectionEnd, currentItem.getString("id"));

                                    mode.finish();

                                    return true;
                                }

                                @Override
                                public void onDestroyActionMode(ActionMode mode) {
                                    mActionMode = null;
                                }
                            }, ActionMode.TYPE_FLOATING);
                            break;
                        }
                    }
                }

                return tv.onTouchEvent(event);
            }
        });
    }

    public void registerSelectionListener(final String[] menuItems, final ReactTextView view) {
        view.setCustomSelectionActionModeCallback(new Callback() {
            @Override
            public boolean onPrepareActionMode(ActionMode mode, Menu menu) {
                // Called when action mode is first created. The menu supplied
                // will be used to generate action buttons for the action mode
                menu.removeItem(android.R.id.copy);
                menu.removeItem(android.R.id.shareText);
                menu.removeItem(android.R.id.selectAll);

                return true;
            }

            @Override
            public boolean onCreateActionMode(ActionMode mode, Menu menu) {
                for (int i = 0; i < menuItems.length; i++) {
                    menu.add(0, i, 0, menuItems[i]);
                }
                return true;
            }

            @Override
            public void onDestroyActionMode(ActionMode mode) {
            }

            @Override
            public boolean onActionItemClicked(ActionMode mode, MenuItem item) {
                int selectionStart = view.getSelectionStart();
                int selectionEnd = view.getSelectionEnd();
                String selectedText = view.getText().toString().substring(selectionStart, selectionEnd);

                // Dispatch event
                onSelectNativeEvent(view, menuItems[item.getItemId()], selectedText, selectionStart, selectionEnd, "");

                mode.finish();

                return true;
            }

        });
    }

    public void onSelectNativeEvent(ReactTextView view, String eventType, String content, int selectionStart, int selectionEnd, String highlightId) {
        WritableMap event = Arguments.createMap();
        event.putString("eventType", eventType);
        event.putString("content", content);
        event.putInt("selectionStart", selectionStart);
        event.putInt("selectionEnd", selectionEnd);
        event.putString("highlightId", highlightId);

        // Dispatch
        ReactContext reactContext = (ReactContext) view.getContext();
        reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
                view.getId(),
                "topSelection",
                event
        );
    }

    @Override
    public Map getExportedCustomDirectEventTypeConstants() {
        return MapBuilder.builder()
                .put(
                        "topSelection",
                        MapBuilder.of(
                                "registrationName","onSelection"))
                .build();
    }
}

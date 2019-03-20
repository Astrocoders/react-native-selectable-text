package com.astrocoders.selectabletext;

import android.view.Menu;
import android.view.MenuItem;
import android.view.ActionMode;
import android.view.ActionMode.Callback;

import java.util.Map;

import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.events.RCTEventEmitter;

import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.views.text.ReactTextView;
import com.facebook.react.views.text.ReactTextViewManager;

import java.util.List;
import java.util.ArrayList;


public class RNSelectableTextManager extends ReactTextViewManager {
    public static final String REACT_CLASS = "RNSelectableText";


    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @Override
    public ReactTextView createViewInstance(ThemedReactContext context) {
        return new ReactTextView(context);
    }


    @ReactProp(name = "menuItems")
    public void setMenuItems(ReactTextView textView, ReadableArray items) {
        List<String> result = new ArrayList<String>(items.size());
        for (int i = 0; i < items.size(); i++) {
            result.add(items.getString(i));
        }

        registerSelectionListener(result.toArray(new String[items.size()]), textView);
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
                // Called when an action mode is about to be exited and
            }

            @Override
            public boolean onActionItemClicked(ActionMode mode, MenuItem item) {
                int selectionStart = view.getSelectionStart();
                int selectionEnd = view.getSelectionEnd();
                String selectedText = view.getText().toString().substring(selectionStart, selectionEnd);

                // Dispatch event
                onSelectNativeEvent(view, menuItems[item.getItemId()], selectedText, selectionStart, selectionEnd);

                mode.finish();

                return true;
            }

        });
    }

    public void onSelectNativeEvent(ReactTextView view, String eventType, String content, int selectionStart, int selectionEnd) {
        WritableMap event = Arguments.createMap();
        event.putString("eventType", eventType);
        event.putString("content", content);
        event.putInt("selectionStart", selectionStart);
        event.putInt("selectionEnd", selectionEnd);

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

package com.astrocoders.selectabletext;

import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.bridge.WritableMap;

import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.uimanager.ReactTextView;


public class RNSelectableTextManager extends SimpleViewManager<ReactTextView> {
  public static final String REACT_CLASS = "RNSelectableText";

  String[] menuItems;

  @Override
  public String getName() {
    return REACT_CLASS;
  }

  @Overrid
  public ReactTextView createViewInstance(ThemedReactContext context){
    return new ReactTextView(context);
  }

  public RNSelectableTextManager(Context context) {
    super(context);

    registerSelectionListener(view)
  }

  @ReactProp(name = "menuItems")
  public void setMenuItems(ReactTextView textView, String[] items) {
    menuItems = items;
  }

  public void registerSelectionListener(ReactTextView view) {
    view.setCustomSelectionActionModeCallback(new Callback() {
        @Override
        public boolean onPrepareActionMode(ActionMode mode, Menu menu) {
            menu.clear();
            return true;
        }

        @Override
        public boolean onCreateActionMode(ActionMode mode, Menu menu) {
            // Called when action mode is first created. The menu supplied
            // will be used to generate action buttons for the action mode

            for (int i=0; i<menuItems.length; i++) { 
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

            int min = 0;
            int max = view.getText().length();
            if (view.isFocused()) {
              // TODO: yield selection positions back to user also
              final int selStart = view.getSelectionStart();
              final int selEnd = view.getSelectionEnd();

              min = Math.max(0, Math.min(selStart, selEnd));
              max = Math.max(0, Math.max(selStart, selEnd));
            }
            // Perform your definition lookup with the selected text
            final CharSequence selectedText = view.getText().subSequence(min, max);

            // Finish and close the ActionMode
            mode.finish();

            // Dispatch event
            onSelectNativeEvent(menuItems[item.getItemId()], selectedText);

            return true;
            return false;
        }

    });
  }

  public void onSelectNativeEvent(String eventType, String content) {
    WritableMap event = Arguments.createMap();
    event.putString("eventType", eventType);
    event.putString("content", content);

    // Dispatch
    ReactContext reactContext = (ReactContext)getContext();
    reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
      getId(),
      "topChange",
      event
    );
  }

  @Override
  public Map getExportedCustomDirectEventTypeConstants() {
    return MapBuilder.of(
        "topChange",
        MapBuilder.of("onSelection"));
  }
}

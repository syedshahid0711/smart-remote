package com.smartnova.remote;

import android.os.Bundle;
import com.getcapacitor.BridgeActivity;

public class MainActivity extends BridgeActivity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        registerPlugin(IRBlasterPlugin.class);
        super.onCreate(savedInstanceState);
    }
}

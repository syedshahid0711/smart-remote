package com.smartnova.remote;

import android.hardware.ConsumerIrManager;
import android.content.Context;
import android.os.Build;
import android.util.Log;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import org.json.JSONArray;

@CapacitorPlugin(name = "IRBlaster")
public class IRBlasterPlugin extends Plugin {

    private ConsumerIrManager irManager;

    @Override
    public void load() {
        irManager = (ConsumerIrManager) getContext().getSystemService(Context.CONSUMER_IR_SERVICE);
    }

    @PluginMethod
    public void hasIrEmitter(PluginCall call) {
        JSObject ret = new JSObject();
        if (irManager == null) {
            ret.put("hasEmitter", false);
        } else {
            ret.put("hasEmitter", irManager.hasIrEmitter());
        }
        call.resolve(ret);
    }

    @PluginMethod
    public void transmit(PluginCall call) {
        if (irManager == null || !irManager.hasIrEmitter()) {
            call.reject("No IR emitter found on this device.");
            return;
        }

        int frequency = call.getInt("frequency", 38000);
        
        try {
            JSONArray patternJson = call.getArray("pattern");
            int[] pattern = new int[patternJson.length()];
            for (int i = 0; i < patternJson.length(); i++) {
                pattern[i] = patternJson.getInt(i);
            }
            
            irManager.transmit(frequency, pattern);
            
            JSObject ret = new JSObject();
            ret.put("success", true);
            call.resolve(ret);
        } catch (Exception e) {
            Log.e("IRBlaster", "Error transmitting IR", e);
            call.reject("Failed to transmit IR signal: " + e.getMessage());
        }
    }
}

import 'dart:convert';
import 'dart:developer';

class MaceraYoluHelper {
  static const String _logPrefix = 'MaceraYolu';
  
  /// Macera Yolu içeriklerinin debug bilgilerini loglar
  static void logDebugInfo(String message) {
    log('$_logPrefix: $message');
    print('🎮 $_logPrefix Debug: $message');
  }
  
  /// H5P content detection için JavaScript kodu
  static String getH5PDetectionScript() {
    return '''
      (function() {
        var debugInfo = {
          timestamp: new Date().toISOString(),
          userAgent: navigator.userAgent,
          h5pDetected: typeof H5P !== 'undefined',
          h5pInstances: [],
          maceraElements: [],
          isMobile: /Android|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent),
                     webViewDetected: document.cookie.includes('derslig_webview=1') || 
                            document.cookie.includes('derslig_mobile_app=true')
        };
        
        // H5P instances kontrol et
        if (typeof H5P !== 'undefined' && H5P.instances) {
          debugInfo.h5pInstances = H5P.instances.map(function(instance, index) {
            return {
              index: index,
              libraryName: instance.libraryInfo ? instance.libraryInfo.machineName : 'unknown',
              hasContainer: !!(instance.\$container && instance.\$container[0]),
              containerClasses: instance.\$container && instance.\$container[0] ? 
                Array.from(instance.\$container[0].classList) : []
            };
          });
        }
        
        // Macera Yolu elements kontrol et
        var maceraSelectors = [
          '[data-content-type="macera"]',
          '.macera-yolu',
          '.h5p-macera-yolu',
          '[class*="macera"]',
          '[id*="macera"]'
        ];
        
        maceraSelectors.forEach(function(selector) {
          var elements = document.querySelectorAll(selector);
          if (elements.length > 0) {
            debugInfo.maceraElements.push({
              selector: selector,
              count: elements.length,
              elements: Array.from(elements).map(function(el) {
                return {
                  tagName: el.tagName,
                  classes: Array.from(el.classList),
                  id: el.id,
                  visible: el.offsetWidth > 0 && el.offsetHeight > 0,
                  hasIframes: el.querySelectorAll('iframe').length > 0
                };
              })
            });
          }
        });
        
                 // Console'a debug bilgilerini yazdır
         console.log('Derslig Macera Yolu Debug Info:', JSON.stringify(debugInfo, null, 2));
         console.log('🍪 Current cookies:', document.cookie);
         
         // WebView detection iyileştirmesi
         if (!debugInfo.webViewDetected) {
           console.warn('⚠️ WebView detection failed - cookies may not be set properly');
         }
        
        // Mobile app'e debug bilgilerini gönder
        if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
          window.flutter_inappwebview.callHandler('maceraYoluDebug', debugInfo);
        }
        
        return debugInfo;
      })();
    ''';
  }
  
  /// Macera Yolu content fix için JavaScript kodu
  static String getMaceraYoluFixScript() {
    return '''
             (function() {
         console.log('🎮 Macera Yolu Fix Script Started');
         
         // H5P Error Prevention and Polyfills
         function preventH5PErrors() {
           // H5P.Utils polyfill if missing
           if (typeof H5P !== 'undefined' && !H5P.Utils) {
             H5P.Utils = H5P.Utils || {};
             console.log('🎮 H5P.Utils polyfill applied');
           }
           
           // maxAllowedLevel polyfill for video
           if (typeof maxAllowedLevel === 'undefined') {
             window.maxAllowedLevel = 100;
             console.log('🎮 maxAllowedLevel polyfill applied');
           }
           
           // Drop library Utils polyfill
           if (typeof window.Drop !== 'undefined' && !window.Drop.Utils) {
             window.Drop.Utils = {};
             console.log('🎮 Drop.Utils polyfill applied');
           }
         }
         
         // H5P Mobile Optimization
         function optimizeH5PForMobile() {
           if (typeof H5P === 'undefined') {
             console.log('H5P not found, skipping H5P optimizations');
             return;
           }
          
          console.log('H5P detected, applying mobile optimizations');
          
          // Global H5P settings override
          if (H5P.preventInit) {
            H5P.preventInit = false;
          }
          
          // H5P instances optimization
          if (H5P.instances) {
            H5P.instances.forEach(function(instance, index) {
              if (!instance) return;
              
              console.log('Optimizing H5P instance ' + index);
              
              // Trigger resize for mobile layout
              if (instance.trigger) {
                instance.trigger('resize');
              }
              
              // Container optimizations
              if (instance.\$container && instance.\$container[0]) {
                var container = instance.\$container[0];
                
                // Mobile-friendly styles
                container.style.maxWidth = '100%';
                container.style.width = '100%';
                container.style.height = 'auto';
                container.style.touchAction = 'manipulation';
                container.style.webkitTouchCallout = 'none';
                container.style.webkitUserSelect = 'none';
                container.style.userSelect = 'none';
                
                // Fix for iframe scaling
                var iframes = container.querySelectorAll('iframe');
                iframes.forEach(function(iframe) {
                  iframe.style.maxWidth = '100%';
                  iframe.style.width = '100%';
                  iframe.style.height = 'auto';
                  iframe.setAttribute('allowfullscreen', 'true');
                });
                
                // Macera Yolu specific fixes
                if (container.classList.contains('h5p-macera-yolu') ||
                    container.querySelector('[data-content-type="macera"]') ||
                    container.innerHTML.includes('macera')) {
                  
                  console.log('🎮 Macera Yolu content detected in H5P instance');
                  
                  // Touch event fixes for Macera Yolu
                  container.addEventListener('touchstart', function(e) {
                    e.stopPropagation();
                  }, { passive: true });
                  
                  container.addEventListener('touchend', function(e) {
                    e.stopPropagation();
                    
                    // Convert touch to click for better interaction
                    var touch = e.changedTouches[0];
                    var clickEvent = new MouseEvent('click', {
                      bubbles: true,
                      cancelable: true,
                      view: window,
                      clientX: touch.clientX,
                      clientY: touch.clientY
                    });
                    
                    setTimeout(function() {
                      e.target.dispatchEvent(clickEvent);
                    }, 50);
                  }, { passive: true });
                  
                  // Enable all pointer events
                  container.style.pointerEvents = 'auto';
                  
                  // Fix z-index issues
                  container.style.zIndex = '1000';
                  container.style.position = 'relative';
                }
              }
            });
          }
        }
        
        // Direct Macera Yolu element fixes
        function fixMaceraYoluElements() {
          var selectors = [
            '[data-content-type="macera"]',
            '.macera-yolu',
            '.h5p-macera-yolu',
            '[class*="macera"]'
          ];
          
          selectors.forEach(function(selector) {
            var elements = document.querySelectorAll(selector);
            
            elements.forEach(function(element) {
              console.log('🎮 Fixing Macera Yolu element:', selector);
              
              // Mobile optimization
              element.style.maxWidth = '100%';
              element.style.width = '100%';
              element.style.height = 'auto';
              element.style.overflow = 'visible';
              element.style.touchAction = 'manipulation';
              element.style.webkitTouchCallout = 'none';
              element.style.webkitUserSelect = 'none';
              element.style.pointerEvents = 'auto';
              
              // Fix nested iframes
              var iframes = element.querySelectorAll('iframe');
              iframes.forEach(function(iframe) {
                iframe.style.maxWidth = '100%';
                iframe.style.width = '100%';
                iframe.style.border = 'none';
                iframe.setAttribute('allowfullscreen', 'true');
                iframe.setAttribute('allow', 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture');
              });
              
              // Add mobile-friendly event handlers
              element.addEventListener('click', function(e) {
                console.log('🎮 Macera Yolu element clicked');
                e.stopPropagation();
              });
            });
          });
        }
        
        // Execute fixes
        try {
          // Prevent H5P errors first
          preventH5PErrors();
          
          // Immediate execution
          optimizeH5PForMobile();
          fixMaceraYoluElements();
          
          // Delayed execution for dynamic content
          setTimeout(function() {
            preventH5PErrors();
            optimizeH5PForMobile();
            fixMaceraYoluElements();
          }, 1000);
          
          setTimeout(function() {
            preventH5PErrors();
            optimizeH5PForMobile();
            fixMaceraYoluElements();
          }, 3000);
          
          // Watch for dynamic content changes
          if (typeof MutationObserver !== 'undefined') {
            var observer = new MutationObserver(function(mutations) {
              var needsReapply = false;
              
              mutations.forEach(function(mutation) {
                if (mutation.addedNodes) {
                  for (var i = 0; i < mutation.addedNodes.length; i++) {
                    var node = mutation.addedNodes[i];
                    if (node.nodeType === 1) {
                      // Check for H5P or Macera content
                      if (node.classList && (
                          node.classList.contains('h5p-content') ||
                          node.classList.contains('h5p-macera-yolu') ||
                          node.querySelector && (
                            node.querySelector('[data-content-type="macera"]') ||
                            node.querySelector('.h5p-content')
                          )
                        )) {
                        needsReapply = true;
                        break;
                      }
                    }
                  }
                }
              });
              
              if (needsReapply) {
                console.log('🎮 New Macera/H5P content detected, reapplying fixes');
                setTimeout(function() {
                  preventH5PErrors();
                  optimizeH5PForMobile();
                  fixMaceraYoluElements();
                }, 500);
              }
            });
            
            observer.observe(document.body, {
              childList: true,
              subtree: true,
              attributes: true,
              attributeFilter: ['class', 'style']
            });
          }
          
        } catch (error) {
          console.error('🎮 Macera Yolu fix error:', error);
        }
        
        console.log('🎮 Macera Yolu Fix Script Completed');
      })();
    ''';
  }
  
  /// WebView içerisinde Macera Yolu problemlerini tespit eder
  static Future<Map<String, dynamic>> detectProblems(Function jsRunner) async {
    try {
      final result = await jsRunner(getH5PDetectionScript());
      if (result != null && result is String) {
        return json.decode(result);
      }
    } catch (e) {
      logDebugInfo('Error detecting problems: $e');
    }
    return {};
  }
  
  /// Kullanıcıya görsel uyarı mesajı göstermek için bilgi
  static Map<String, String> getUserFriendlyMessages() {
    return {
      'loading': 'Macera Yolu içeriği yükleniyor... Lütfen bekleyin.',
      'not_supported': 'Bu içerik şu anda mobil uygulamada tam olarak desteklenmiyor. Web tarayıcısında açmayı deneyin.',
      'touch_issue': 'Etkileşim sorunu tespit edildi. Ekrana dokunmayı tekrar deneyin.',
      'loading_failed': 'İçerik yüklenemedi. İnternet bağlantınızı kontrol edin ve tekrar deneyin.',
      'general_error': 'Macera Yolu içeriğinde bir sorun oluştu. Lütfen uygulamayı yeniden başlatın.'
    };
  }
} 
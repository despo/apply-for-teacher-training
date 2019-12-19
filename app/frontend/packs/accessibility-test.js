import "axe-core";

(function (window, document, axe) {
  function AccessibilityTest (selector, callback) {
    if (typeof callback !== 'function') {
      return
    }

    var element = document.querySelector(selector)

    if (!element) {
      return callback()
    }

    // var dataDisabledRules = element.getAttribute('data-excluded-rules')
    // var disabledRules = dataDisabledRules ? JSON.parse(dataDisabledRules) : []
    //
    // var axeRules = {}
    //
    // disabledRules.forEach(function (rule) {
    //   axeRules[rule] = { enabled: false }
    // })

    var axeOptions = {
      restoreScroll: true,
      include: [selector]
    }

    axe.run(selector, axeOptions, function (err, results) {
      if (err) {
        return callback('aXe Error: ' + err)
      }

      if (typeof results === "undefined") {
        return callback('aXe Error: Expected results but none returned')
      }

      var consoleErrorText = _consoleErrorText(results.violations, results.url)
      var bodyClass = results.violations.length === 0 ? "js-test-a11y-success" : "js-test-a11y-failed"
      document.body.classList.add(bodyClass);
      document.body.classList.add("js-test-a11y-finished");

      callback(undefined, consoleErrorText, _processAxeResultsForPage(results))
    })
  }

  var _consoleErrorText = function(violations, url) {
    if (violations.length !== 0) {
      return (
        '\n' + 'Accessibility issues at ' +
        url + '\n\n' +
        violations.map(function (violation) {
          var help = 'Problem: ' + violation.help + ' (' + violation.id + ')'
          var helpUrl = 'Try fixing it with this help: ' + violation.helpUrl
          var htmlAndTarget = violation.nodes.map(_renderNode).join('\n\n')

          return [
            help,
            htmlAndTarget,
            helpUrl
          ].join('\n\n\n')
        }).join('\n\n- - -\n\n')
      )
    } else {
      return false
    }
  }

  var _processAxeResultsForPage = function(results) {
    return {
      violations: _mapSummaryAndCause(results.violations),
      incompleteWarnings: _mapSummaryAndCause(results.incomplete)
    }
  }

  var _mapSummaryAndCause = function(resultsArray) {
    return resultsArray.map(function (result) {
      var cssSelector = result.nodes.map(function (node) {
                          return {
                            'selector': node.target,
                            'reasons': node.any.map(function(item) {
                              return item.message
                            })
                          }
                        })
      return {
        'id': result.id,
        'summary': result.help,
        'selectors': cssSelector,
        'url': result.helpUrl
      }
    })
  }

  var _renderNode = function (node) {
    return (
      ' Check the HTML:\n' +
      ' `' + node.html + '`\n' +
      ' found with the selector:\n' +
      ' "' + node.target.join(', ') + '"'
    )
  }

  var _throwUncaughtError = function (error) {
    // aXe swallows throw errors so we pass it through a setTimeout
    // so that it's not in aXe's context
    setTimeout(function () {
      throw new Error(error)
    }, 0)
  }

  // Cut the mustard at IE9+ since aXe only works with those browsers.
  // http://responsivenews.co.uk/post/18948466399/cutting-the-mustard
  if (document.addEventListener) {
    document.addEventListener('DOMContentLoaded', function () {
      AccessibilityTest('body', function (axeError, consoleErrorText) {
        if (axeError) {
          _throwUncaughtError(axeError)
        }

        if (consoleErrorText) {
          _throwUncaughtError(consoleErrorText)
        }
      })
    })
  }
})(window, document, window.axe)

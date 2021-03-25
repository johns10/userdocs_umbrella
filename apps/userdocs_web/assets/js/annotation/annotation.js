function annotations(name) {
  const functions_object = {
    "Badge": window.userdocs.badge,
    "Outline": window.userdocs.outline,
    "Badge Outline": window.userdocs.badgeOutline,
    "Blur": window.userdocs.blur
  }
  return functions_object[name]
}

function badge(step) {
  // Get normal vars
  const selector = step.attrs.element.selector;
  const strategy = step.attrs.element.strategy;
  const element = window.userdocs.getElement(strategy, selector);

  // Get vars for these elements
  const badge_x = step.attrs.annotation.x_orientation;
  const badge_y = step.attrs.annotation.y_orientation;
  const size = step.attrs.annotation.size;
  const labelText = step.attrs.annotation.label;
  const color = step.attrs.annotation.color;
  const xOffset = step.attrs.annotation.x_offset;
  const yOffset = step.attrs.annotation.y_offset;
  const fontSize = step.attrs.annotation.font_size;;

  var badge = document.createElement('span');
  badge = window.userdocs.styleBadge(badge, size, fontSize, color);

  var label = document.createElement('span');
  label = window.userdocs.styleLabel(label, size, fontSize, labelText);

  const rect = element.getBoundingClientRect();

  var wrapper = document.createElement('div');
  wrapper = window.userdocs.styleWrapper(wrapper, rect, size, xOffset, yOffset, badge_x, badge_y);

  try {
    document.body.appendChild(wrapper);
    wrapper.appendChild(badge); 
    badge.appendChild(label);
    window.active_annotations.push(wrapper);
  } catch(error) {
    step.status = "failed"
    step.error = error
  }
}

function outline(step, configuration) {
  console.log("outline")
  const selector = step.attrs.element.selector
  const strategy = step.attrs.element.strategy
  const outlineColor = step.attrs.annotation.color
  const thickness = step.attrs.annotation.thickness + 'px';
  const element = window.userdocs.getElement(strategy, selector)
  const outline = window.userdocs.createOutlineElement(element, outlineColor, thickness)

  try {
    console.log("try append child")
    document.body.appendChild(outline)
    console.log("try active annotations")
    window.active_annotations.push(outline)
  } catch(error) {
    step.status = "failed"
    step.errors.push(error)
  }
}

function badgeOutline(step) {
  console.log("Applying badge outline annotation")

  const selector = step.attrs.element.selector
  const strategy = step.attrs.element.strategy
  const thickness = step.attrs.annotation.thickness + 'px';
  const badge_x = step.attrs.annotation.x_orientation
  const badge_y = step.attrs.annotation.y_orientation
  const size = step.attrs.annotation.size
  const labelText = step.attrs.annotation.label
  const color = step.attrs.annotation.color
  const xOffset = step.attrs.annotation.x_offset
  const yOffset = step.attrs.annotation.y_offset
  const fontSize = step.attrs.annotation.font_size;
  const element = window.userdocs.getElement(strategy, selector)
  const outline = window.userdocs.createOutlineElement(element, color, thickness)

  var badge = document.createElement('span');
  badge = window.userdocs.styleBadge(badge, size, fontSize, color)

  var label = document.createElement('span');
  label = window.userdocs.styleLabel(label, size, fontSize, labelText);

  const rect = element.getBoundingClientRect();

  var wrapper = document.createElement('div');
  wrapper = window.userdocs.styleWrapper(wrapper, rect, size, xOffset, yOffset, badge_x, badge_y)

  try {
    document.body.appendChild(wrapper);
    document.body.appendChild(outline);
    wrapper.appendChild(badge); 
    badge.appendChild(label);
    window.active_annotations.push(wrapper);
    window.active_annotations.push(outline);
  } catch(error) {
    step.status = "failed"
    step.errors.push(error)
  }
}

function blur(step) {
  const selector = step.attrs.element.selector
  const strategy = step.attrs.element.strategy
  const element = window.userdocs.getElement(strategy, selector)

  console.log("blur")
  console.log(element)

  element.style.textShadow = "0 0 5px rgba(0,0,0,0.5)";
  element.style.color = "transparent";
}

function styleLabel(label, size, fontSize, labelText) {
  label.style.position = 'relative';
  label.style.top = ((size * 2 - fontSize) / 2).toString() + 'px';
  label.textContent = labelText;
  label.style.color = 'white';

  return label;
}

function styleBadge(badge, size, fontSize, color) {
  badge.style.position = 'relative';
  badge.style.display = 'inline-table';
  badge.style.width = (2 * size).toString() + 'px';
  badge.style.height = (2 * size).toString() + 'px';
  badge.style.borderRadius = '50%';
  badge.style.fontSize = fontSize.toString() + 'px';
  badge.style.textAlign = 'center';
  badge.style.background = color;

  return badge;
}

function styleWrapper(wrapper, rect, size, xOffset, yOffset, badge_x, badge_y) {

  const x_calcs = {
    L: Math.round(rect.left - size + xOffset).toString() + 'px',
    M: Math.round(rect.left + rect.width/2 - size + xOffset).toString() + 'px',
    R: Math.round(rect.right - size + xOffset).toString() + 'px'
  }
  const y_calcs = {
    T: Math.round(rect.top - size + yOffset).toString() + 'px',
    M: Math.round(rect.bottom - rect.height/2 - size + yOffset).toString() + 'px',
    B: Math.round(rect.bottom - size + yOffset).toString() + 'px'
  }

  const x = x_calcs[badge_x]
  const y = y_calcs[badge_y]

  wrapper.style.display = 'static';
  wrapper.style.justifyContent = 'center';
  wrapper.style.alignItems = 'center';
  wrapper.style.minHeight = '';
  wrapper.style.position = 'fixed';
  wrapper.style.top = y;
  wrapper.style.left = x;
  wrapper.style.zIndex = 999999;

  return wrapper
}

function createOutlineElement(element, outlineColor, thickness) {
  const rect = element.getBoundingClientRect();
  const outline = document.createElement('div');
  
  outline.style.position = 'fixed';
  outline.style.width = Math.round(rect.width).toString() + 'px'
  outline.style.height = Math.round(rect.height).toString() + 'px'
  outline.style.outline = outlineColor + ' solid ' + thickness;
  outline.style.top = Math.round(rect.top).toString() + 'px';
  outline.style.left = Math.round(rect.left).toString() + 'px';
  outline.style.zIndex = 99999;

  return outline
}

module.exports.annotations = annotations;
module.exports.badge = badge;
module.exports.styleLabel = styleLabel;
module.exports.styleBadge = styleBadge;
module.exports.styleWrapper = styleWrapper;
module.exports.outline = outline;
module.exports.createOutlineElement = createOutlineElement;
module.exports.badgeOutline = badgeOutline;
module.exports.blur = blur;




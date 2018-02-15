/*
 * generated by Xtext 2.10.0
 */
package org.parisoft.noop.ui.labeling

import com.google.inject.Inject
import java.io.File
import org.eclipse.emf.edit.ui.provider.AdapterFactoryLabelProvider
import org.eclipse.jface.viewers.StyledString
import org.eclipse.xtext.Keyword
import org.eclipse.xtext.ui.label.DefaultEObjectLabelProvider
import org.parisoft.noop.^extension.Classes
import org.parisoft.noop.^extension.Expressions
import org.parisoft.noop.^extension.Members
import org.parisoft.noop.noop.Method
import org.parisoft.noop.noop.NoopClass
import org.parisoft.noop.noop.Variable

/**
 * Provides labels for EObjects.
 * 
 * See https://www.eclipse.org/Xtext/documentation/304_ide_concepts.html#label-provider
 */
class NoopLabelProvider extends DefaultEObjectLabelProvider {

	@Inject extension Members
	@Inject extension Classes
	@Inject extension Expressions

	@Inject
	new(AdapterFactoryLabelProvider delegate) {
		super(delegate);
	}

	def text(NoopClass c) {
		new StyledString(c.name, StyledString::DECORATIONS_STYLER)
	}

	def text(Variable variable) {
		val displayString = new StyledString(variable.name).append(' : ')

		displayString.append(variable.typeOf.name, StyledString::DECORATIONS_STYLER)

		if (variable.isField) {
			displayString.append(''' - «variable.containerClass.name»''', StyledString::QUALIFIER_STYLER)
		}

		return displayString
	}

	def text(Method method) {
		val displayString = new StyledString(method.name).append('(')

		method.params.forEach [ param, i |
			displayString.append(param.type.name, StyledString::DECORATIONS_STYLER)
			displayString.append(param.dimension.map['''[«value?.valueOf»]'''].join, StyledString::DECORATIONS_STYLER)
			displayString.append(' ').append(param.name)

			if (i < method.params.length - 1) {
				displayString.append(', ')
			}
		]

		displayString.append(')').append(': ')
		displayString.append(method.typeOf.name, StyledString::DECORATIONS_STYLER)
		displayString.append(method.dimensionOf.map['''[«it»]'''].join, StyledString::DECORATIONS_STYLER)
		displayString.append(''' - «method.containerClass.name»''', StyledString::QUALIFIER_STYLER)

		return displayString
	}

	def image(NoopClass c) {
		if (c.isVoid) {
			'Void.png'
		} else {
			'Class.png'
		}
	}

	def image(Variable v) {
		'''«IF v.isField»Field«IF v.isPrivate»_private«ELSE»_public«ENDIF»«IF v.isOverride»_override«ENDIF»«ELSE»Variable«ENDIF».png'''.
			toString
	}

	def image(Method m) {
		'''Method«IF m.isPrivate»_private«ELSE»_public«ENDIF»«IF m.isOverride»_override«ENDIF».png'''.toString
	}

	def image(File file) {
		'File.png'
	}

	def image(String string) {
		'Keyword.png'
	}

	def image(Keyword k) {
		'Keyword.png'
	}
}
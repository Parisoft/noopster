package org.parisoft.noop.ui.hover

import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.ui.editor.hover.html.DefaultEObjectHoverProvider
import org.parisoft.noop.^extension.Classes
import org.parisoft.noop.^extension.Expressions
import org.parisoft.noop.^extension.Members
import org.parisoft.noop.noop.Method
import org.parisoft.noop.noop.NoopClass
import org.parisoft.noop.noop.Variable
import org.parisoft.noop.ui.labeling.NoopLabelProvider
import utils.Images

import static extension org.eclipse.xtext.EcoreUtil2.*
import static extension java.lang.Integer.*

class NoopHoverProvider extends DefaultEObjectHoverProvider {

	@Inject extension Images
	@Inject extension Classes
	@Inject extension Members
	@Inject extension Expressions
	@Inject extension NoopLabelProvider

	override protected getFirstLine(EObject o) {
		switch (o) {
			NoopClass: '''
				«val classes = o.superClasses»
				«o.image.toTag»
				«FOR i : 0 ..< classes.size»
					<ul style="list-style-type:none">
					«IF i > 0»extends «ENDIF»<b>«classes.get(i).name»</b>
				«ENDFOR»
				«FOR i : 0 ..< classes.size»
					</ul>
				«ENDFOR»
			'''
			Variable: '''
				«val type = o.typeOf.name»
				«val dimension = o.dimensionOf.map['''<b>[</b>«it»<b>]</b>'''].join»
				«val container = o.containerClass.name»
				«IF o.isField»
					«val value = if (o.isConstant) {
						try {
							val n = o.value?.valueOf as Integer
							''' = «n»<sub>10</sub>|«n.toHexString.toUpperCase»<sub>16</sub>|«n.toBinaryString»<sub>2</sub>'''
						} catch (Exception e) {
							''
						}
					}»
					«o.image.toTag»&nbsp;<b>«type»</b>«dimension» «container».<b>«o.name»«value»</b>
				«ELSE»
					«val method = o.getContainerOfType(Method)»
					«val params = method.params.map['''«it.type.name»«it.dimension.map['''[«value?.valueOf»]'''].join»'''].join(', ')»
					«o.image.toTag»&nbsp;<b>«type»</b>«dimension» <b>«o.name»</b> - «container».«method.name»(«params»)
				«ENDIF»
			'''
			Method: '''
				«val type = o.typeOf.name»
				«val dimension = o.dimensionOf.map['''<b>[</b>«it»<b>]</b>'''].join»
				«val container = o.containerClass.name»
				«val params = o.params.map['''«it.type.name»«it.dimension.map['''[«value?.valueOf»]'''].join» «name»'''].join(', ')»
				«o.image.toTag»&nbsp;<b>«type»</b>«dimension» «container».<b>«o.name»(«params»)</b>
			'''
			default:
				super.getFirstLine(o)
		}
	}

	override protected getDocumentation(EObject o) {
		var doc = super.getDocumentation(o)
		var index = -1

		if (doc === null) {
			val overriden = if (o instanceof Variable) {
					o.containerClass.superClass.allFieldsTopDown.findFirst[o.isOverrideOf(it)]
				} else if (o instanceof Method) {
					o.containerClass.superClass.allMethodsTopDown.findFirst[o.isOverrideOf(it)]
				}

			if (overriden === null || (doc = super.getDocumentation(overriden)) === null) {
				return null
			}
		}

		if ((index = doc.indexOf('*/')) !== -1) {
			return doc.substring(0, index)
		}

		if (doc.endsWith('/')) {
			return doc.substring(0, doc.length - 1)
		}

		return doc
	}

	private def toTag(String image) '''<img src="«image.toFileURL»" style="float:left">'''

}

package org.parisoft.noop.ui

import com.google.inject.Module
import com.google.inject.Binder
import org.eclipse.xtext.resource.clustering.IResourceClusteringPolicy
import org.eclipse.xtext.resource.clustering.DynamicResourceClusteringPolicy

class NoopOverrideGuiceModule implements Module {
	
	override configure(Binder binder) {
		binder.bind(IResourceClusteringPolicy).to(DynamicResourceClusteringPolicy);
	}
	
}